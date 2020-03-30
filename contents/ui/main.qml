import QtQuick 2.7
import QtQuick.Window 2.2
//import org.kde.kwin 2.0 as KWin
import org.kde.kwin 2.0 as KWinLib
//import org.kde.kwin 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as Plasma

// This is how we get the activity background.
import org.kde.plasma.activityswitcher 1.0 as ActivitySwitcher
import org.kde.activities 0.1 as Activities
//import org.kde.plasma.extras 2.0 as PlasmaExtras

// Let's use some blur!
import QtGraphicalEffects 1.0

import "../code/createClients.js" as CreateClients

//BLAH

	// dashboard background.  Holds window thumbnails.  I hope.
Window {
	id: dashboard
	visible: true
	height: dashboard.screenHeight - (dashboardActivityChanger.height + dashboardDesktopChanger.height)*dashboard.scalingFactor
	width: dashboard.screenWidth
	x: 0
	y: 0
	//flags: Qt.WindowTransparentForInput //| Qt.X11BypassWindowManagerHint
	flags: Qt.WA_TranslucentBackground | Qt.CustomizeWindowHint | Qt.WindowTitleHint | Qt.BypassGraphicsProxyWidget | Qt.X11BypassWindowManagerHint

	color: '#00000000'

	property var windowId: 0
	property var scalingFactor: 2
	property var activeScreen: 0
	property int screenWidth: 0
	property int screenHeight: 0
	property var screenRatio: 0
	property int dockHeight: 0
	property var newDesktop: -1

	property var clientsVisible: { new Array }
	function _getDockHeight() {
		// We have to account for any docks.  Which is a hassle, but eh.
		var c;
		var dockHeight = 0;
		for (c = 0; c < workspace.clientList().length; c++) {
			if (workspace.clientList()[c].dock) {
				dockHeight = dockHeight + workspace.clientList()[c].height;
			}
		}
		return dockHeight;
	}
	function returnNumberOfDesktops() {
		return workspace.desktops;
	}
	ActivitiesContainer {
		// Instantiate our activity container.
		id: allActivities
	}
	Item {
		id: mainBackground
		anchors.fill: parent
		x: 0
		y: 0
		opacity: 1


		// This creates a mouseArea for the rectangle.  We change the height of our dock.

		// First, we create some states: visible, and otherwise.
		states: [
			State {
				name: 'visible'
			},
			State {
				name: 'invisible'
			}
		]
		//NumberAnimation { id: fadeToBlack; running: false; alwaysRunToEnd: true; target: foregroundDarken; property: "opacity"; to: 1; from: 0}
		//NumberAnimation { id: fadeFromBlack; running: false; alwaysRunToEnd: true; target: foregroundDarken; property: "opacity"; to: 0; from: 1}
	}
	Timer {
		id: timer
		interval: 200
		onTriggered: {
		}
	}

	DesktopChanger {
		id: dashboardDesktopChanger
	}

	ActivityChanger {
		id: dashboardActivityChanger
	}

		function toggleBoth() {
			//dashboardDesktopChanger.populateVisibleClients();
			if (mainBackground.state == 'visible') {
				endAnim.restart();
				//dashboardDesktopChanger.enableVisibleClients();
				mainBackground.state = 'invisible';
			} else if (mainBackground.state == 'invisible') {
				dashboardDesktopChanger.width = dashboard.screenWidth;
				dashboardActivityChanger.width = dashboard.screenWidth;
				dashboard.height = dashboard.screenHeight;
				dashboard.width = dashboard.screenWidth;
				initAnim.restart();
				mainBackground.state = 'visible';
				mainBackground.visible = true;
				timer.restart();
				dashboardActivityChanger.requestActivate();
				dashboardDesktopChanger.requestActivate();
				dashboardActivityChanger.raise();
				dashboardDesktopChanger.raise();
			}
		}
		ParallelAnimation {
			id: initAnim
			NumberAnimation { target: dashboardDesktopChanger; property: "y"; from: -dashboardDesktopChanger.height*dashboard.scalingFactor; to: 0}
			//NumberAnimation { target: dashboardDesktopChanger; property: "height"; from: 0; to: 220;}
			//NumberAnimation { target: dashPlasmaBack; property: "y"; from: -dashboardDesktopChanger.height*dashboard.scalingFactor; to: 0}
			NumberAnimation { target: dashboardActivityChanger; property: "y"; from: dashboard.screenHeight; to: dashboard.screenHeight - (100*dashboard.scalingFactor)}
			NumberAnimation { target: activitySwitcherPlasmaBack; property: "y"; from: dashboard.screenHeight; to: dashboard.screenHeight - (100*dashboard.scalingFactor)}
			NumberAnimation { target: dashboard; property: "opacity"; to: 1; from: 0}
			// Expensive!
			SequentialAnimation {
				ParallelAnimation {
					//NumberAnimation { target: blurBackground; property: "radius"; to: 32; from: 1}
					//NumberAnimation { target: backgroundDarken; property: "opacity"; to: 0.5; from: 0}
				}
			}
			onRunningChanged: {
				if (!initAnim.running) {
				}
			}
		}
		ParallelAnimation {
			id: endAnim
			SequentialAnimation {
				ParallelAnimation {
					NumberAnimation { target: dashboardDesktopChanger; property: "y"; to: -dashboardDesktopChanger.height*dashboard.scalingFactor; duration: 100}
					//NumberAnimation { target: dashboardDesktopChanger; property: "height"; to: 0; duration: 100}
					//NumberAnimation { target: dashPlasmaBack; property: "y"; to: -dashboardDesktopChanger.height*dashboard.scalingFactor; duration: 100}
					NumberAnimation { target: dashboardActivityChanger; property: "y"; to: dashboard.screenHeight; from: dashboard.screenHeight - (100*dashboard.scalingFactor); duration: 100}
					NumberAnimation { target: activitySwitcherPlasmaBack; property: "y"; to: dashboard.screenHeight; from: dashboard.screenHeight - (100*dashboard.scalingFactor); duration: 100}
				}
			}

			onRunningChanged: {
				if (!endAnim.running) {
					dashboard.y = dashboard.screenHeight;
					mainBackground.state = 'invisible';
					mainBackground.visible = false;
				}
			}
		}
		Component.onCompleted: {
			dashboard.dockHeight = dashboard._getDockHeight();
			dashboard.activeScreen =  workspace.clientArea(KWinLib.MaximizedArea, workspace.activeScreen, workspace.currentDesktop);
			dashboard.screenWidth = dashboard.activeScreen.width;
			dashboard.screenHeight = dashboard.activeScreen.height + dashboard._getDockHeight();
			dashboard.screenRatio = dashboard.activeScreen.width/dashboard.activeScreen.height;
			mainBackground.state = 'invisible';

			// Try and register a shortcut, maybe.
			if (KWin.registerShortcut) {
			KWin.registerShortcut("OVERVIEW: Show kwinOverview",
															"Show kwinOverview",
															"Meta+A",
															function() {
																toggleBoth()
															}
				);
			}
		}
}
