package com.datasul.framework.ui.progressmonitor {
	import flash.events.Event;
	
	public class ProgressMonitorEvent extends Event {
		
		public static const HIDE:String = "hideProgressMonitor";
		
		public static const SHOW:String = "showProgressMonitor";
		
		public static const ERROR:String = "errorProgressMonitor";
		
		public static const DETAIL_ERROR:String = "detailErrorProgressMonitor";
		
		/**
		 * Atributo responsável por armazenar o tipo de
		 * determinado objeto a ser dispachado neste evento
		 */
		[Bindable]
		public var parameter:String;
		
		[Bindable]
		public var otherParameters:Object;
		
		public function ProgressMonitorEvent(type:String, _parameter:String = null, _otherParameters:Object = null) {
			super(type);
			this.parameter = _parameter;
			this.otherParameters = _otherParameters;
		}
	}
}
