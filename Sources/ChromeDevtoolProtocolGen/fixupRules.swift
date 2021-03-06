let fixRules: [FixupRule] = [
  // browser
  .propertyType(domain: "Accessibility", type: "AXValue", property: "value", realType: "any"),
  .propertyType(domain: "Animation", type: "Animation", property: "playbackRate", realType: "float"),
  .propertyType(domain: "Animation", type: "Animation", property: "startTime", realType: "integer"),
  .propertyType(domain: "Animation", type: "Animation", property: "currentTime", realType: "integer"),
  .propertyType(domain: "Animation", type: "AnimationEffect", property: "delay", realType: "integer"),
  .propertyType(domain: "Animation", type: "AnimationEffect", property: "endDelay", realType: "integer"),
  .propertyType(domain: "Animation", type: "AnimationEffect", property: "iterationStart", realType: "integer"),
  .propertyType(domain: "Animation", type: "AnimationEffect", property: "iterations", realType: "integer"),
  .propertyType(domain: "Animation", type: "AnimationEffect", property: "duration", realType: "integer"),
  .commandParamsType(domain: "Animation", command: "seekAnimations", params: "currentTime", realType: "integer"),
  .commandParamsType(domain: "Animation", command: "setPlaybackRate", params: "playbackRate", realType: "float"),
  .commandParamsType(domain: "Animation", command: "setTiming", params: "duration", realType: "integer"),
  .commandParamsType(domain: "Animation", command: "setTiming", params: "delay", realType: "integer"),
  .propertyType(domain: "ApplicationCache", type: "ApplicationCache", property: "size", realType: "integer"),
  .propertyType(domain: "ApplicationCache", type: "ApplicationCache", property: "creationTime", realType: "integer"),
  .propertyType(domain: "ApplicationCache", type: "ApplicationCache", property: "updateTime", realType: "integer"),
  .commandParamsType(domain: "Audits", command: "getEncodedResponse", params: "quality", realType: "float"),
  .propertyType(domain: "CSS", type: "CSSStyleSheetHeader", property: "startLine", realType: "integer"),
  .propertyType(domain: "CSS", type: "CSSStyleSheetHeader", property: "startColumn", realType: "integer"),
  .propertyType(domain: "CSS", type: "CSSStyleSheetHeader", property: "length", realType: "integer"),
  .propertyType(domain: "CSS", type: "CSSStyleSheetHeader", property: "endLine", realType: "integer"),
  .propertyType(domain: "CSS", type: "CSSStyleSheetHeader", property: "endColumn", realType: "integer"),
  .propertyType(domain: "CSS", type: "RuleUsage", property: "startOffset", realType: "integer"),
  .propertyType(domain: "CSS", type: "RuleUsage", property: "endOffset", realType: "integer"),
  .propertyType(domain: "CSS", type: "MediaQueryExpression", property: "value", realType: "number"),
  .propertyType(domain: "CSS", type: "MediaQueryExpression", property: "computedLength", realType: "integer"),
  .propertyType(domain: "CSS", type: "PlatformFontUsage", property: "glyphCount", realType: "integer"),
  .propertyType(domain: "CSS", type: "FontVariationAxis", property: "minValue", realType: "number"),
  .propertyType(domain: "CSS", type: "FontVariationAxis", property: "maxValue", realType: "number"),
  .propertyType(domain: "CSS", type: "FontVariationAxis", property: "defaultValue", realType: "number"),
  .propertyType(domain: "CacheStorage", type: "DataEntry", property: "responseTime", realType: "number"),
  .propertyType(domain: "DOM", type: "RGBA", property: "a", realType: "float"),
  .propertyType(domain: "DOM", type: "Rect", property: "x", realType: "integer"),
  .propertyType(domain: "DOM", type: "Rect", property: "y", realType: "integer"),
  .propertyType(domain: "DOM", type: "Rect", property: "width", realType: "integer"),
  .propertyType(domain: "DOM", type: "Rect", property: "height", realType: "integer"),
  .propertyType(domain: "DOMSnapshot", type: "DOMNode", property: "scrollOffsetX", realType: "integer"),
  .propertyType(domain: "DOMSnapshot", type: "DOMNode", property: "scrollOffsetY", realType: "integer"),
  .propertyType(domain: "DOMSnapshot", type: "DocumentSnapshot", property: "scrollOffsetX", realType: "integer"),
  .propertyType(domain: "DOMSnapshot", type: "DocumentSnapshot", property: "scrollOffsetY", realType: "integer"),
  .propertyType(domain: "DOMSnapshot", type: "DocumentSnapshot", property: "contentWidth", realType: "integer"),
  .propertyType(domain: "DOMSnapshot", type: "DocumentSnapshot", property: "contentHeight", realType: "integer"),
  .commandParamsType(domain: "DeviceOrientation", command: "setDeviceOrientationOverride", params: "alpha", realType: "number"),
  .commandParamsType(domain: "DeviceOrientation", command: "setDeviceOrientationOverride", params: "beta", realType: "number"),
  .commandParamsType(domain: "DeviceOrientation", command: "setDeviceOrientationOverride", params: "gamma", realType: "number"),
  .commandParamsType(domain: "Emulation", command: "setCPUThrottlingRate", params: "rate", realType: "number"),
  .commandParamsType(domain: "Emulation", command: "setDeviceMetricsOverride", params: "deviceScaleFactor", realType: "number"),
  .commandParamsType(domain: "Emulation", command: "setDeviceMetricsOverride", params: "scale", realType: "number"),
  .commandParamsType(domain: "Emulation", command: "setGeolocationOverride", params: "latitude", realType: "float"),
  .commandParamsType(domain: "Emulation", command: "setGeolocationOverride", params: "longitude", realType: "float"),
  .commandParamsType(domain: "Emulation", command: "setGeolocationOverride", params: "accuracy", realType: "number"),
  .commandParamsType(domain: "Emulation", command: "setPageScaleFactor", params: "pageScaleFactor", realType: "number"),
  .commandParamsType(domain: "Emulation", command: "setVirtualTimePolicy", params: "budget", realType: "number"),
  .commandParamsType(domain: "HeadlessExperimental", command: "beginFrame", params: "frameTimeTicks", realType: "integer"),
  .commandParamsType(domain: "HeadlessExperimental", command: "beginFrame", params: "interval", realType: "integer"),
  .propertyType(domain: "IndexedDB", type: "DatabaseWithObjectStores", property: "version", realType: "integer"),
  .propertyType(domain: "IndexedDB", type: "Key", property: "number", realType: "integer"),
  .propertyType(domain: "IndexedDB", type: "Key", property: "date", realType: "integer"),
  .propertyType(domain: "Input", type: "TouchPoint", property: "x", realType: "number"),
  .propertyType(domain: "Input", type: "TouchPoint", property: "y", realType: "number"),
  .propertyType(domain: "Input", type: "TouchPoint", property: "radiusX", realType: "number"),
  .propertyType(domain: "Input", type: "TouchPoint", property: "radiusY", realType: "number"),
  .propertyType(domain: "Input", type: "TouchPoint", property: "rotationAngle", realType: "number"),
  .propertyType(domain: "Input", type: "TouchPoint", property: "force", realType: "number"),
  .propertyType(domain: "Input", type: "TouchPoint", property: "tangentialPressure", realType: "number"),
  .propertyType(domain: "Input", type: "TouchPoint", property: "id", realType: "number"),
  .typeType(domain: "Input", type: "TimeSinceEpoch", realType: "number"),
  .commandParamsType(domain: "Input", command: "dispatchMouseEvent", params: "x", realType: "number"),
  .commandParamsType(domain: "Input", command: "dispatchMouseEvent", params: "y", realType: "number"),
  .commandParamsType(domain: "Input", command: "dispatchMouseEvent", params: "force", realType: "number"),
  .commandParamsType(domain: "Input", command: "dispatchMouseEvent", params: "tangentialPressure", realType: "number"),
  .commandParamsType(domain: "Input", command: "dispatchMouseEvent", params: "deltaX", realType: "number"),
  .commandParamsType(domain: "Input", command: "dispatchMouseEvent", params: "deltaY", realType: "number"),
  .commandParamsType(domain: "Input", command: "emulateTouchFromMouseEvent", params: "deltaX", realType: "number"),
  .commandParamsType(domain: "Input", command: "emulateTouchFromMouseEvent", params: "deltaY", realType: "number"),
  .commandParamsType(domain: "Input", command: "synthesizePinchGesture", params: "x", realType: "number"),
  .commandParamsType(domain: "Input", command: "synthesizePinchGesture", params: "y", realType: "number"),
  .commandParamsType(domain: "Input", command: "synthesizePinchGesture", params: "scaleFactor", realType: "number"),
  .commandParamsType(domain: "Input", command: "synthesizeScrollGesture", params: "x", realType: "number"),
  .commandParamsType(domain: "Input", command: "synthesizeScrollGesture", params: "y", realType: "number"),
  .commandParamsType(domain: "Input", command: "synthesizeScrollGesture", params: "xDistance", realType: "number"),
  .commandParamsType(domain: "Input", command: "synthesizeScrollGesture", params: "yDistance", realType: "number"),
  .commandParamsType(domain: "Input", command: "synthesizeScrollGesture", params: "xOverscroll", realType: "number"),
  .commandParamsType(domain: "Input", command: "synthesizeScrollGesture", params: "yOverscroll", realType: "number"),
  .commandParamsType(domain: "Input", command: "synthesizeTapGesture", params: "x", realType: "number"),
  .commandParamsType(domain: "Input", command: "synthesizeTapGesture", params: "y", realType: "number"),
  .propertyType(domain: "LayerTree", type: "PictureTile", property: "x", realType: "number"),
  .propertyType(domain: "LayerTree", type: "PictureTile", property: "y", realType: "integer"),
  .propertyType(domain: "LayerTree", type: "Layer", property: "offsetX", realType: "integer"),
  .propertyType(domain: "LayerTree", type: "Layer", property: "offsetY", realType: "integer"),
  .propertyType(domain: "LayerTree", type: "Layer", property: "width", realType: "integer"),
  .propertyType(domain: "LayerTree", type: "Layer", property: "height", realType: "integer"),
  .propertyType(domain: "LayerTree", type: "Layer", property: "anchorX", realType: "integer"),
  .propertyType(domain: "LayerTree", type: "Layer", property: "anchorY", realType: "integer"),
  .propertyType(domain: "LayerTree", type: "Layer", property: "anchorZ", realType: "integer"),
  .commandParamsType(domain: "LayerTree", command: "profileSnapshot", params: "minDuration", realType: "number"),
  .commandParamsType(domain: "LayerTree", command: "replaySnapshot", params: "scale", realType: "number"),
  .propertyType(domain: "Log", type: "ViolationSetting", property: "threshold", realType: "number"),
  .propertyType(domain: "Memory", type: "SamplingProfileNode", property: "size", realType: "number"),
  .propertyType(domain: "Memory", type: "SamplingProfileNode", property: "total", realType: "number"),
  .propertyType(domain: "Memory", type: "Module", property: "size", realType: "number"),
  .typeType(domain: "Network", type: "TimeSinceEpoch", realType: "number"),
  .typeType(domain: "Network", type: "MonotonicTime", realType: "number"),
  .propertyType(domain: "Network", type: "ResourceTiming", property: "requestTime", realType: "integer"),
  .propertyType(domain: "Network", type: "ResourceTiming", property: "proxyStart", realType: "integer"),
  .propertyType(domain: "Network", type: "ResourceTiming", property: "proxyEnd", realType: "integer"),
  .propertyType(domain: "Network", type: "ResourceTiming", property: "dnsStart", realType: "integer"),
  .propertyType(domain: "Network", type: "ResourceTiming", property: "dnsEnd", realType: "integer"),
  .propertyType(domain: "Network", type: "ResourceTiming", property: "connectStart", realType: "integer"),
  .propertyType(domain: "Network", type: "ResourceTiming", property: "connectEnd", realType: "integer"),
  .propertyType(domain: "Network", type: "ResourceTiming", property: "sslStart", realType: "integer"),
  .propertyType(domain: "Network", type: "ResourceTiming", property: "sslEnd", realType: "integer"),
  .propertyType(domain: "Network", type: "ResourceTiming", property: "workerStart", realType: "integer"),
  .propertyType(domain: "Network", type: "ResourceTiming", property: "workerReady", realType: "integer"),
  .propertyType(domain: "Network", type: "ResourceTiming", property: "workerFetchStart", realType: "integer"),
  .propertyType(domain: "Network", type: "ResourceTiming", property: "workerRespondWithSettled", realType: "integer"),
  .propertyType(domain: "Network", type: "ResourceTiming", property: "sendStart", realType: "integer"),
  .propertyType(domain: "Network", type: "ResourceTiming", property: "sendEnd", realType: "integer"),
  .propertyType(domain: "Network", type: "ResourceTiming", property: "pushStart", realType: "integer"),
  .propertyType(domain: "Network", type: "ResourceTiming", property: "pushEnd", realType: "integer"),
  .propertyType(domain: "Network", type: "ResourceTiming", property: "receiveHeadersEnd", realType: "integer"),
  .propertyType(domain: "Network", type: "Response", property: "connectionId", realType: "number"),
  .propertyType(domain: "Network", type: "Response", property: "encodedDataLength", realType: "number"),
  .propertyType(domain: "Network", type: "WebSocketFrame", property: "opcode", realType: "number"),
  .propertyType(domain: "Network", type: "CachedResource", property: "bodySize", realType: "number"),
  .propertyType(domain: "Network", type: "Initiator", property: "lineNumber", realType: "number"),
  .propertyType(domain: "Network", type: "Initiator", property: "columnNumber", realType: "number"),
  .propertyType(domain: "Network", type: "Cookie", property: "expires", realType: "number"),
  .propertyType(domain: "Network", type: "LoadNetworkResourcePageResult", property: "netError", realType: "number"),
  .propertyType(domain: "Network", type: "LoadNetworkResourcePageResult", property: "httpStatusCode", realType: "number"),
  .commandParamsType(domain: "Network", command: "emulateNetworkConditions", params: "latency", realType: "number"),
  .commandParamsType(domain: "Network", command: "emulateNetworkConditions", params: "downloadThroughput", realType: "number"),
  .commandParamsType(domain: "Network", command: "emulateNetworkConditions", params: "uploadThroughput", realType: "number"),
  .eventParamsType(domain: "Network", event: "loadingFinished", params: "encodedDataLength", realType: "number"),
  .propertyType(domain: "Page", type: "FrameResource", property: "contentSize", realType: "number"),
  .propertyType(domain: "Page", type: "ScreencastFrameMetadata", property: "offsetTop", realType: "integer"),
  .propertyType(domain: "Page", type: "ScreencastFrameMetadata", property: "pageScaleFactor", realType: "float"),
  .propertyType(domain: "Page", type: "ScreencastFrameMetadata", property: "deviceWidth", realType: "integer"),
  .propertyType(domain: "Page", type: "ScreencastFrameMetadata", property: "deviceHeight", realType: "integer"),
  .propertyType(domain: "Page", type: "ScreencastFrameMetadata", property: "scrollOffsetX", realType: "integer"),
  .propertyType(domain: "Page", type: "ScreencastFrameMetadata", property: "scrollOffsetY", realType: "integer"),
  .propertyType(domain: "Page", type: "VisualViewport", property: "offsetX", realType: "integer"),
  .propertyType(domain: "Page", type: "VisualViewport", property: "offsetY", realType: "integer"),
  .propertyType(domain: "Page", type: "VisualViewport", property: "pageX", realType: "integer"),
  .propertyType(domain: "Page", type: "VisualViewport", property: "pageY", realType: "integer"),
  .propertyType(domain: "Page", type: "VisualViewport", property: "clientWidth", realType: "integer"),
  .propertyType(domain: "Page", type: "VisualViewport", property: "clientHeight", realType: "integer"),
  .propertyType(domain: "Page", type: "VisualViewport", property: "scale", realType: "float"),
  .propertyType(domain: "Page", type: "VisualViewport", property: "zoom", realType: "float"),
  .propertyType(domain: "Page", type: "Viewport", property: "x", realType: "integer"),
  .propertyType(domain: "Page", type: "Viewport", property: "y", realType: "integer"),
  .propertyType(domain: "Page", type: "Viewport", property: "width", realType: "integer"),
  .propertyType(domain: "Page", type: "Viewport", property: "height", realType: "integer"),
  .propertyType(domain: "Page", type: "Viewport", property: "scale", realType: "float"),
  .commandParamsType(domain: "Page", command: "printToPDF", params: "scale", realType: "float"),
  .commandParamsType(domain: "Page", command: "printToPDF", params: "paperWidth", realType: "integer"),
  .commandParamsType(domain: "Page", command: "printToPDF", params: "paperHeight", realType: "integer"),
  .commandParamsType(domain: "Page", command: "printToPDF", params: "marginTop", realType: "integer"),
  .commandParamsType(domain: "Page", command: "printToPDF", params: "marginBottom", realType: "integer"),
  .commandParamsType(domain: "Page", command: "printToPDF", params: "marginLeft", realType: "integer"),
  .commandParamsType(domain: "Page", command: "printToPDF", params: "marginRight", realType: "integer"),
  .commandParamsType(domain: "Page", command: "setDeviceMetricsOverride", params: "deviceScaleFactor", realType: "float"),
  .commandParamsType(domain: "Page", command: "setDeviceMetricsOverride", params: "scale", realType: "float"),
  .commandParamsType(domain: "Page", command: "setDeviceOrientationOverride", params: "alpha", realType: "float"),
  .commandParamsType(domain: "Page", command: "setDeviceOrientationOverride", params: "beta", realType: "float"),
  .commandParamsType(domain: "Page", command: "setDeviceOrientationOverride", params: "gamma", realType: "float"),
  .commandParamsType(domain: "Page", command: "setGeolocationOverride", params: "latitude", realType: "float"),
  .commandParamsType(domain: "Page", command: "setGeolocationOverride", params: "longitude", realType: "float"),
  .commandParamsType(domain: "Page", command: "setGeolocationOverride", params: "accuracy", realType: "float"),
  .eventParamsType(domain: "Page", event: "frameScheduledNavigation", params: "delay", realType: "integer"),
  .eventParamsType(domain: "Page", event: "downloadProgress", params: "totalBytes", realType: "integer"),
  .eventParamsType(domain: "Page", event: "downloadProgress", params: "receivedBytes", realType: "integer"),
  .propertyType(domain: "Performance", type: "Metric", property: "value", realType: "number"),
  .propertyType(domain: "ServiceWorker", type: "ServiceWorkerVersion", property: "scriptLastModified", realType: "number"),
  .propertyType(domain: "ServiceWorker", type: "ServiceWorkerVersion", property: "scriptResponseTime", realType: "number"),
  .propertyType(domain: "Storage", type: "UsageForType", property: "usage", realType: "number"),
  .commandParamsType(domain: "Storage", command: "overrideQuotaForOrigin", params: "quotaSize", realType: "number"),
  .propertyType(domain: "SystemInfo", type: "GPUDevice", property: "vendorId", realType: "number"),
  .propertyType(domain: "SystemInfo", type: "GPUDevice", property: "deviceId", realType: "number"),
  .propertyType(domain: "SystemInfo", type: "GPUDevice", property: "subSysId", realType: "number"),
  .propertyType(domain: "SystemInfo", type: "GPUDevice", property: "revision", realType: "number"),
  .propertyType(domain: "SystemInfo", type: "ProcessInfo", property: "cpuTime", realType: "number"),
  .commandParamsType(domain: "Tracing", command: "start", params: "bufferUsageReportingInterval", realType: "number"),
  .eventParamsType(domain: "Tracing", event: "bufferUsage", params: "percentFull", realType: "number"),
  .eventParamsType(domain: "Tracing", event: "bufferUsage", params: "eventCount", realType: "number"),
  .eventParamsType(domain: "Tracing", event: "bufferUsage", params: "value", realType: "number"),
  .propertyType(domain: "WebAudio", type: "ContextRealtimeData", property: "currentTime", realType: "number"),
  .propertyType(domain: "WebAudio", type: "ContextRealtimeData", property: "renderCapacity", realType: "number"),
  .propertyType(domain: "WebAudio", type: "ContextRealtimeData", property: "callbackIntervalMean", realType: "number"),
  .propertyType(domain: "WebAudio", type: "ContextRealtimeData", property: "callbackIntervalVariance", realType: "number"),
  .propertyType(domain: "WebAudio", type: "BaseAudioContext", property: "callbackBufferSize", realType: "number"),
  .propertyType(domain: "WebAudio", type: "BaseAudioContext", property: "maxOutputChannelCount", realType: "number"),
  .propertyType(domain: "WebAudio", type: "BaseAudioContext", property: "sampleRate", realType: "number"),
  .propertyType(domain: "WebAudio", type: "AudioNode", property: "numberOfInputs", realType: "number"),
  .propertyType(domain: "WebAudio", type: "AudioNode", property: "numberOfOutputs", realType: "number"),
  .propertyType(domain: "WebAudio", type: "AudioNode", property: "channelCount", realType: "number"),
  .propertyType(domain: "WebAudio", type: "AudioParam", property: "defaultValue", realType: "number"),
  .propertyType(domain: "WebAudio", type: "AudioParam", property: "minValue", realType: "number"),
  .propertyType(domain: "WebAudio", type: "AudioParam", property: "maxValue", realType: "number"),
  .eventParamsType(domain: "WebAudio", event: "nodesConnected", params: "sourceOutputIndex", realType: "number"),
  .eventParamsType(domain: "WebAudio", event: "nodesConnected", params: "destinationInputIndex", realType: "number"),
  .eventParamsType(domain: "WebAudio", event: "nodesDisconnected", params: "sourceOutputIndex", realType: "number"),
  .eventParamsType(domain: "WebAudio", event: "nodesDisconnected", params: "destinationInputIndex", realType: "number"),
  .eventParamsType(domain: "WebAudio", event: "nodeParamConnected", params: "sourceOutputIndex", realType: "number"),
  .eventParamsType(domain: "WebAudio", event: "nodeParamDisconnected", params: "sourceOutputIndex", realType: "number"),
  .typeType(domain: "Media", type: "Timestamp", realType: "number"),
  // js
  .propertyType(domain: "Debugger", type: "SearchMatch", property: "lineNumber", realType: "integer"),
  .commandParamsType(domain: "Debugger", command: "enable", params: "maxScriptsCacheSize", realType: "integer"),
  .propertyType(domain: "HeapProfiler", type: "SamplingHeapProfileNode", property: "selfSize", realType: "integer"),
  .propertyType(domain: "HeapProfiler", type: "SamplingHeapProfileSample", property: "size", realType: "integer"),
  .propertyType(domain: "HeapProfiler", type: "SamplingHeapProfileSample", property: "ordinal", realType: "integer"),
  .commandParamsType(domain: "HeapProfiler", command: "startSampling", params: "samplingInterval", realType: "integer"),
  .eventParamsType(domain: "HeapProfiler", event: "lastSeenObjectId", params: "timestamp", realType: "integer"),
  .propertyType(domain: "Profiler", type: "Profile", property: "startTime", realType: "integer"),
  .propertyType(domain: "Profiler", type: "Profile", property: "endTime", realType: "integer"),
  .propertyType(domain: "Profiler", type: "RuntimeCallCounterInfo", property: "value", realType: "number"),
  .propertyType(domain: "Profiler", type: "RuntimeCallCounterInfo", property: "time", realType: "number"),
  .eventParamsType(domain: "Profiler", event: "preciseCoverageDeltaUpdate", params: "timestamp", realType: "number"),
  .propertyType(domain: "Runtime", type: "RemoteObject", property: "value", realType: "any"),
  .propertyType(domain: "Runtime", type: "CallArgument", property: "value", realType: "any"),
  .typeType(domain: "Runtime", type: "Timestamp", realType: "number"),
  .typeType(domain: "Runtime", type: "TimeDelta", realType: "number"),
]