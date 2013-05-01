/*
 *+------------------------------------------------------------------------+
 *| Licensed Materials - Property of IBM
 *| IBM Cognos Products: Viewer
 *| (C) Copyright IBM Corp. 2001, 2010
 *|
 *| US Government Users Restricted Rights - Use, duplication or
 *| disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 *|
 *+------------------------------------------------------------------------+
 */
/*-----------------------------------------------------------------------------------------------------

Class :			CObserver

Description :

-----------------------------------------------------------------------------------------------------*/

function CObserver(subject) {

	this.m_subject = subject;
	this.m_observers = new Array();
}

function CObserver_attach(observer, callback, evt) {
	// verify that when attaching an observer, the observer has implemented a 'update' function
	if(observer == null || typeof observer.update != "function") {
		alert('Notification Frame Work Error : attach failed');
		return false;
	}

	var stateChange = new CState(this.m_subject, observer, callback ? callback : null, evt ? evt : null);
	this.m_observers[this.m_observers.length] = stateChange;
	return true;
}

function CObserver_detach(observer) {
}

function CObserver_hasObserver(observer)
{
	var bHasObserver = false;
	for (var idxObs = 0; idxObs < this.m_observers.length; idxObs++)
	{
		if (this.m_observers[idxObs].getObserver() == observer)
		{
			bHasObserver = true;
			break;
		}
	}
	return bHasObserver;
}

function CObserver_notify(evt) {
	var i = 0;
	if(typeof evt != "undefined" && evt != null) {
		for(i = 0; i < this.m_observers.length; ++i) {
			if(this.m_observers[i].getEvt() == evt) {
				var theObserver = this.m_observers[i].getObserver();
				var theCallback = this.m_observers[i].getCallback();
				var cachedHandler = theObserver.update;

				theObserver.update = theCallback;
				theObserver.update(this.m_observers[i]);
				theObserver.update = cachedHandler;
			}
		}
	} else {
		for(i = 0; i < this.m_observers.length; ++i) {
			this.m_observers[i].getObserver().update(this.m_observers[i].getSubject());
		}
	}
}


CObserver.prototype.attach = CObserver_attach;
CObserver.prototype.detach = CObserver_detach;
CObserver.prototype.notify = CObserver_notify;
CObserver.prototype.hasObserver = CObserver_hasObserver;



/*-----------------------------------------------------------------------------------------------------

Class :			CState

Description :

-----------------------------------------------------------------------------------------------------*/
function CState(subject, observer, callback,evt) {
	this.m_subject = subject;
	this.m_observer = observer;
	this.m_callback = callback;
	this.m_evt = evt;
}

function CState_getObserver() {
	return this.m_observer;
}

function CState_getCallback() {
	return this.m_callback;
}

function CState_getSubject() {
	return this.m_subject;
}

function CState_getEvt() {
	return this.m_evt;
}


CState.prototype.getObserver = CState_getObserver;
CState.prototype.getCallback = CState_getCallback;
CState.prototype.getSubject = CState_getSubject;
CState.prototype.getEvt = CState_getEvt;
