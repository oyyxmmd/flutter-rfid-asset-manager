package com.example.flutter_application_1.rfid

import android.content.Context
import android.os.Handler
import android.os.Looper
import com.ubx.usdk.USDKManager
import com.ubx.usdk.rfid.RfidManager
import com.ubx.usdk.rfid.aidl.IRfidCallback
import com.ubx.usdk.rfid.aidl.RfidDate
import com.ubx.usdk.rfid.util.CMDCode
import com.ubx.usdk.rfid.util.ErrorCode
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class UrovoDirectRfidBridge(
    private val context: Context,
    messenger: BinaryMessenger,
) : MethodChannel.MethodCallHandler, EventChannel.StreamHandler {

    private val mainHandler = Handler(Looper.getMainLooper())
    private val methodChannel = MethodChannel(
        messenger,
        METHOD_CHANNEL,
    )
    private val eventChannel = EventChannel(
        messenger,
        EVENT_CHANNEL,
    )

    private var eventSink: EventChannel.EventSink? = null
    private var rfidManager: RfidManager? = null
    private var latestRfidDate: RfidDate? = null
    private var moduleFirmware: String? = null
    private var readerFirmware: String? = null
    private var isInitialized = false
    private var isConnected = false
    private var callbackRegistered = false

    private val callback = object : IRfidCallback {
        override fun onInventoryTag(
            cmd: Byte,
            pc: String?,
            crc: String?,
            epc: String?,
            ant: Byte,
            rssi: String?,
            frequency: String?,
            phase: Int,
            count: Int,
            readerId: String?,
        ) {
            emitEvent(
                mapOf(
                    "type" to "inventoryTag",
                    "cmd" to cmd.toInt(),
                    "pc" to pc,
                    "crc" to crc,
                    "epc" to epc,
                    "ant" to ant.toInt(),
                    "rssi" to rssi,
                    "frequency" to frequency,
                    "phase" to phase,
                    "count" to count,
                    "readerId" to readerId,
                ),
            )
        }

        override fun onInventoryTagEnd(
            antennaId: Int,
            inventoryCount: Int,
            readRate: Int,
            totalRead: Int,
            cmd: Byte,
        ) {
            emitEvent(
                mapOf(
                    "type" to "inventoryEnd",
                    "antennaId" to antennaId,
                    "inventoryCount" to inventoryCount,
                    "readRate" to readRate,
                    "totalRead" to totalRead,
                    "cmd" to cmd.toInt(),
                ),
            )
        }

        override fun onOperationTag(
            arg0: String?,
            arg1: String?,
            arg2: String?,
            arg3: String?,
            arg4: Int,
            arg5: Byte,
            arg6: Byte,
        ) {
            emitEvent(
                mapOf(
                    "type" to "operationTag",
                    "arg0" to arg0,
                    "arg1" to arg1,
                    "arg2" to arg2,
                    "arg3" to arg3,
                    "arg4" to arg4,
                    "arg5" to arg5.toInt(),
                    "arg6" to arg6.toInt(),
                ),
            )
        }

        override fun onOperationTagEnd(status: Int) {
            emitEvent(
                mapOf(
                    "type" to "operationEnd",
                    "status" to status,
                ),
            )
        }

        override fun refreshSetting(rfidDate: RfidDate?) {
            latestRfidDate = rfidDate
            readerFirmware = rfidDate?.let {
                "${it.getbtMajor().toInt() and 0xFF}.${it.getbtMinor().toInt() and 0xFF}"
            }
            val power = rfidDate?.getbtAryOutputPower()?.firstOrNull()?.toInt()?.and(0xFF)
            emitEvent(
                mapOf(
                    "type" to "settingsRefreshed",
                    "power" to power,
                    "readerFirmware" to readerFirmware,
                    "readId" to rfidDate?.getReadId()?.toInt(),
                ),
            )
        }

        override fun onExeCMDStatus(cmd: Byte, status: Byte) {
            emitEvent(
                mapOf(
                    "type" to "commandStatus",
                    "cmd" to cmd.toInt(),
                    "status" to status.toInt(),
                    "cmdName" to safeFormatCmd(cmd),
                    "statusName" to safeFormatError(status),
                ),
            )
        }
    }

    init {
        methodChannel.setMethodCallHandler(this)
        eventChannel.setStreamHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "isSupported" -> result.success(true)
            "initialize" -> initialize(result)
            "connect" -> connect(call, result)
            "disconnect" -> disconnect(result)
            "startInventory" -> startInventory(call, result)
            "stopInventory" -> stopInventory(result)
            "getOutputPower" -> getOutputPower(result)
            "setOutputPower" -> setOutputPower(call, result)
            "getModuleFirmware" -> result.success(moduleFirmware)
            "refreshReaderFirmware" -> refreshReaderFirmware(result)
            "getCachedStatus" -> result.success(buildStatusMap())
            else -> result.notImplemented()
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    fun dispose() {
        eventChannel.setStreamHandler(null)
        methodChannel.setMethodCallHandler(null)
        unregisterCallback()
        rfidManager?.disConnect()
        rfidManager?.release()
        rfidManager = null
        isConnected = false
        isInitialized = false
    }

    private fun initialize(result: MethodChannel.Result) {
        if (isInitialized && rfidManager != null) {
            result.success(buildStatusMap())
            return
        }
        USDKManager.getInstance().init(context, object : USDKManager.InitListener {
            override fun onStatus(status: USDKManager.STATUS?) {
                mainHandler.post {
                    if (status == USDKManager.STATUS.SUCCESS) {
                        rfidManager = USDKManager.getInstance().getRfidManager()
                        isInitialized = rfidManager != null
                        emitEvent(
                            mapOf(
                                "type" to "lifecycle",
                                "status" to "initialized",
                            ),
                        )
                        result.success(buildStatusMap())
                    } else {
                        emitEvent(
                            mapOf(
                                "type" to "lifecycle",
                                "status" to "initializeFailed",
                            ),
                        )
                        result.error(
                            "RFID_INIT_FAILED",
                            "USDK init failed: ${status?.name ?: "unknown"}",
                            null,
                        )
                    }
                }
            }
        })
    }

    private fun connect(call: MethodCall, result: MethodChannel.Result) {
        val manager = rfidManager
        if (manager == null) {
            result.error("RFID_NOT_INITIALIZED", "Call initialize() before connect()", null)
            return
        }
        val port = call.argument<String>("port") ?: DEFAULT_PORT
        val baudRate = call.argument<Int>("baudRate") ?: DEFAULT_BAUD_RATE
        val connected = manager.connectCom(port, baudRate)
        isConnected = connected
        if (connected) {
            moduleFirmware = manager.getModuleFirmware()
            registerCallbackIfNeeded()
            manager.getFirmwareVersion(manager.getReadId())
            emitEvent(
                mapOf(
                    "type" to "lifecycle",
                    "status" to "connected",
                    "port" to port,
                    "baudRate" to baudRate,
                    "moduleFirmware" to moduleFirmware,
                ),
            )
            result.success(buildStatusMap())
            return
        }
        result.error(
            "RFID_CONNECT_FAILED",
            "Failed to connect to reader on $port @ $baudRate",
            null,
        )
    }

    private fun disconnect(result: MethodChannel.Result) {
        unregisterCallback()
        rfidManager?.disConnect()
        isConnected = false
        emitEvent(
            mapOf(
                "type" to "lifecycle",
                "status" to "disconnected",
            ),
        )
        result.success(buildStatusMap())
    }

    private fun startInventory(call: MethodCall, result: MethodChannel.Result) {
        val manager = requireConnectedManager(result) ?: return
        registerCallbackIfNeeded()
        val session = (call.argument<Int>("session") ?: DEFAULT_SESSION).toByte()
        val target = (call.argument<Int>("target") ?: DEFAULT_TARGET).toByte()
        val repeat = (call.argument<Int>("repeat") ?: DEFAULT_REPEAT).toByte()
        manager.customizedSessionTargetInventory(manager.getReadId(), session, target, repeat)
        emitEvent(
            mapOf(
                "type" to "inventoryStarted",
                "session" to session.toInt(),
                "target" to target.toInt(),
                "repeat" to repeat.toInt(),
            ),
        )
        result.success(
            mapOf(
                "started" to true,
                "session" to session.toInt(),
                "target" to target.toInt(),
                "repeat" to repeat.toInt(),
            ),
        )
    }

    private fun stopInventory(result: MethodChannel.Result) {
        val manager = requireConnectedManager(result) ?: return
        manager.stopInventory()
        emitEvent(mapOf("type" to "inventoryStopped"))
        result.success(mapOf("stopped" to true))
    }

    private fun getOutputPower(result: MethodChannel.Result) {
        val manager = requireConnectedManager(result) ?: return
        registerCallbackIfNeeded()
        manager.getOutputPower(manager.getReadId())
        result.success(
            mapOf(
                "requested" to true,
                "cachedPower" to latestPower(),
            ),
        )
    }

    private fun setOutputPower(call: MethodCall, result: MethodChannel.Result) {
        val manager = requireConnectedManager(result) ?: return
        val power = call.argument<Int>("power")
        if (power == null || power !in 0..33) {
            result.error("RFID_INVALID_POWER", "power must be between 0 and 33", null)
            return
        }
        registerCallbackIfNeeded()
        manager.setOutputPower(manager.getReadId(), power.toByte())
        result.success(
            mapOf(
                "requested" to true,
                "power" to power,
            ),
        )
    }

    private fun refreshReaderFirmware(result: MethodChannel.Result) {
        val manager = requireConnectedManager(result) ?: return
        registerCallbackIfNeeded()
        manager.getFirmwareVersion(manager.getReadId())
        result.success(
            mapOf(
                "requested" to true,
                "cachedReaderFirmware" to readerFirmware,
            ),
        )
    }

    private fun requireConnectedManager(result: MethodChannel.Result): RfidManager? {
        val manager = rfidManager
        if (manager == null || !isInitialized) {
            result.error("RFID_NOT_INITIALIZED", "Call initialize() first", null)
            return null
        }
        if (!isConnected) {
            result.error("RFID_NOT_CONNECTED", "Call connect() first", null)
            return null
        }
        return manager
    }

    private fun buildStatusMap(): Map<String, Any?> {
        return mapOf(
            "initialized" to isInitialized,
            "connected" to isConnected,
            "moduleFirmware" to moduleFirmware,
            "readerFirmware" to readerFirmware,
            "outputPower" to latestPower(),
            "readId" to latestRfidDate?.getReadId()?.toInt(),
        )
    }

    private fun latestPower(): Int? {
        return latestRfidDate?.getbtAryOutputPower()?.firstOrNull()?.toInt()?.and(0xFF)
    }

    private fun registerCallbackIfNeeded() {
        if (!callbackRegistered) {
            rfidManager?.registerCallback(callback)
            callbackRegistered = true
        }
    }

    private fun unregisterCallback() {
        if (callbackRegistered) {
            rfidManager?.unregisterCallback(callback)
            callbackRegistered = false
        }
    }

    private fun emitEvent(event: Map<String, Any?>) {
        mainHandler.post {
            eventSink?.success(event)
        }
    }

    private fun safeFormatCmd(cmd: Byte): String {
        return runCatching { CMDCode.format(cmd) }.getOrElse { "CMD_${cmd.toInt()}" }
    }

    private fun safeFormatError(status: Byte): String {
        return runCatching { ErrorCode.format(status) }.getOrElse { "STATUS_${status.toInt()}" }
    }

    companion object {
        private const val METHOD_CHANNEL = "com.example.flutter_application_1/rfid/urovo_direct/methods"
        private const val EVENT_CHANNEL = "com.example.flutter_application_1/rfid/urovo_direct/events"
        private const val DEFAULT_PORT = "/dev/ttyHSL0"
        private const val DEFAULT_BAUD_RATE = 115200
        private const val DEFAULT_SESSION = 1
        private const val DEFAULT_TARGET = 0
        private const val DEFAULT_REPEAT = 1
    }
}
