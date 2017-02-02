protocol {ViewModuleName}: ViewModule{ //ROOT_CLASS	
	func initialize() //ROOT_INITIALIZE

	weak var {http_module_name}: HTTP! //MODULE_ HTTP
	weak var {sip_module_name}: SIP! //MODULE_HTTP
	weak var {rtsp_module_name}: RTSP? //MODULE_RTSP
}

protocol ViewModule: class{
	var vc: ViewController {get}
}