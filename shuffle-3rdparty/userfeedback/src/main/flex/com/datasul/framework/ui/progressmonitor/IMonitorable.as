package com.datasul.framework.ui.progressmonitor {
	
	import flash.events.IEventDispatcher;
	
	/**
	 *  @eventType com.datasul.framework.ui.progressmonitor.ProgressMonitorEvent.SHOW
	 */
	[Event(name="showProgressMonitor", type="com.datasul.framework.ui.progressmonitor.ProgressMonitorEvent")]
	
	/**
	 *  @eventType com.datasul.framework.ui.progressmonitor.ProgressMonitorEvent.HIDE
	 */
	[Event(name="hideProgressMonitor", type="com.datasul.framework.ui.progressmonitor.ProgressMonitorEvent")]
	
	/**
	 *  @eventType com.datasul.framework.ui.progressmonitor.ProgressMonitorEvent.ERROR
	 */
	[Event(name="errorProgressMonitor", type="com.datasul.framework.ui.progressmonitor.ProgressMonitorEvent")]
	public interface IMonitorable extends IEventDispatcher {
		
		function detailError(e:ProgressMonitorEvent):void;
	
	}
}
