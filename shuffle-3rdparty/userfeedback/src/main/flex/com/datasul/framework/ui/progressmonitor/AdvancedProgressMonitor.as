package com.datasul.framework.ui.progressmonitor {
	import flash.events.Event;
	
	import mx.core.Application;
	import mx.core.UIComponent;
	
	public class AdvancedProgressMonitor {
		
		private var pm:ProgressMonitor;
		
		public function AdvancedProgressMonitor(monitorable:IMonitorable, label:String, parent:UIComponent = null,
				modal:Boolean = true, lockParentOnly:Boolean = false) {
			pm = new ProgressMonitor();
			monitorable.removeEventListener(ProgressMonitorEvent.SHOW, show);
			monitorable.removeEventListener(ProgressMonitorEvent.HIDE, hide);
			monitorable.removeEventListener(ProgressMonitorEvent.ERROR, error);
			this.label = label;
			
			if (parent == null)
				parent = Application.application as UIComponent;
			pm.dockParent = parent;
			pm.modal = modal;
			pm.lockParentOnly = lockParentOnly;
			monitorable.addEventListener(ProgressMonitorEvent.SHOW, show);
			monitorable.addEventListener(ProgressMonitorEvent.HIDE, hide);
			monitorable.addEventListener(ProgressMonitorEvent.ERROR, error);
			pm.addEventListener(ProgressMonitorEvent.DETAIL_ERROR, monitorable.detailError);
		}
		
		private function show(e:Event):void {
			pm.show();
		}
		
		private function error(e:Event):void {
			pm.error(e);
		}
		
		private function hide(e:Event):void {
			pm.hide();
		}
		
		[Bindable]
		public function set label(label:String):void {
			pm.label = label;
		}
	
	}
}
