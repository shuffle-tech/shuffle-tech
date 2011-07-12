package com.datasul.framework.ui.progressmonitor {
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	
	import mx.binding.utils.BindingUtils;
	import mx.core.Application;
	import mx.core.UIComponent;
	
	/**
	 *  @eventType com.datasul.framework.ui.progressmonitor.ProgressMonitorEvent.ERROR
	 */
	[Event(name="errorProgressMonitor", type="com.datasul.framework.ui.progressmonitor.ProgressMonitorEvent")]
	public class SimpleProgressMonitor implements IEventDispatcher {
		
		[Bindable]
		public var parent:UIComponent;
		
		[Bindable]
		public var label:String;
		
		[Bindable]
		public var modal:Boolean = true;
		
		[Bindable]
		public var lockParentOnly:Boolean = false;
		
		[Bindable]
		public var removeLoaderBorderAndBackground:Boolean = false;
		
		private var pm:ProgressMonitor;
		
		public function SimpleProgressMonitor() {
			pm = new ProgressMonitor();
			BindingUtils.bindProperty(pm, "label", this, "label");
			BindingUtils.bindProperty(pm, "modal", this, "modal");
			BindingUtils.bindProperty(pm, "removeLoaderBorderAndBackground", this, "removeLoaderBorderAndBackground");
			BindingUtils.bindProperty(pm, "lockParentOnly", this, "lockParentOnly");
			BindingUtils.bindSetter(function(dockParent:UIComponent):void {
						if (dockParent == null) {
							dockParent = Application.application as UIComponent;
						}
						pm.dockParent = dockParent;
					}, this, "parent");
		}
		
		public function show():void {
			pm.show();
		}
		
		public function error():void {
			pm.error();
		}
		
		public function hide():void {
			pm.hide();
		}
		
		public function hasEventListener(type:String):Boolean {
			return pm.hasEventListener(type);
		}
		
		public function willTrigger(type:String):Boolean {
			return pm.willTrigger(type);
		}
		
		public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0.0,
				useWeakReference:Boolean = false):void {
			pm.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void {
			pm.removeEventListener(type, listener, useCapture);
		}
		
		public function dispatchEvent(event:Event):Boolean {
			return pm.dispatchEvent(event);
		}
		
		public function set loaderAnimationColor(color:uint):void {
			try {
				pm.loaderAnimationColor = color;
			} catch (e:Error) {
				trace("[SimpleProgressMonitor] Não foi possível alterar cor da animação\n", e.getStackTrace());
			}
		}
		
		public function set animationMessage(message:String):void {
			pm.animationMessage = message;
		}
		
		public function set modalBackgroundColor(color:uint):void {
			pm.modalBackgroundColor = color;
		}
	
	}
}
