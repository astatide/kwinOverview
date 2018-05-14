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
			opacity: 1
			flags: Qt.X11BypassWindowManagerHint | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint // won't work without it, apparently.
			visible: true
			x: 0
			y: 0
			color: 'black'
			// Start disabled.  toggleBoth sets this appropriately.
			height: 0
			width: 0
			//width: { activeScreen.width }
			//height: { return activeScreen.height + _getDockHeight() }
			/*property int dockHeight: { return _getDockHeight() }
			property var activeScreen: { workspace.clientArea(KWinLib.MaximizedArea, workspace.activeScreen, workspace.currentDesktop) }
			//property var activeScreen: { workspace.clientArea(MaximizedArea, workspace.activeScreen, workspace.currentDesktop) }
			property int screenWidth: { activeScreen.width }
			property int screenHeight: { return activeScreen.height + _getDockHeight() }
			property var screenRatio: { activeScreen.width/activeScreen.height }
			property int dockHeight: { return _getDockHeight() }*/
			property var activeScreen: 0
			//property var activeScreen: { workspace.clientArea(MaximizedArea, workspace.activeScreen, workspace.currentDesktop) }
			property int screenWidth: 0
			property int screenHeight: 0
			property var screenRatio: 0
			property int dockHeight: 0

			property var clientsVisible: { new Array }

			function _getDockHeight() {
				// We have to account for any docks.  Which is a hassle, but eh.
				var c;
				var dockHeight = 0;
				for (c = 0; c < workspace.clientList().length; c++) {
					//console.log(workspace.clientList()[c].dock)
					if (workspace.clientList()[c].dock) {
						dockHeight = dockHeight + workspace.clientList()[c].height;
					}
				}
				return dockHeight;
			}

			Item {
				id: mainBackground
				width: dashboard.screenWidth
				anchors.fill: parent
				//height: main.screenHeight
		    height: dashboard.screenHeight
				x: 0
				y: 0
				//visible: true
				opacity: 1

				// This creates a mouseArea for the rectangle.  We change the height of our dock.
				MouseArea {
					anchors.fill: parent
					enabled: true
					onClicked: {
						/*if (mainBackground.state == 'visible') {
							//endAnim.running = true;
							//dashboardBackground.visible = false;
							//dashboard.visible = false;
							mainBackground.state = 'invisible';
						} else if (mainBackground.state == 'invisible') {
							//initAnim.running = true;
							//dashboardBackground.visible = true;
							//dashboard.visible = true;
							mainBackground.state = 'visible';
						}*/
						toggleBoth();
						//dashboard.visible = false;
					}
				}

				// First, we create some states: visible, and otherwise.
				states: [
					State {
						name: 'visible'
						//PropertyChanges { target: dashboard; visible: true }
					},
					State {
						name: 'invisible'
						//PropertyChanges { target: dashboard; visible: false }
					}
				]
				// These are just temporary to get it out of my way.  We'll change them later.
				ParallelAnimation {
					id: initAnim
					NumberAnimation { target: dash; property: "y"; to: 0}
					//NumberAnimation { target: dashboard; property: "opacity"; to: 1; from: dashboard.opacity}
					//NumberAnimation { target: dashboardBackground; property: "opacity"; to: 1; from: dashboard.opacity}
					// Expensive!
					NumberAnimation { target: blurBackground; property: "radius"; to: 32; from: 1}
					//NumberAnimation { target: mainBackground; property: "opacity"; to: 1; from: mainBackground.opacity}
					NumberAnimation { target: backgroundDarken; property: "opacity"; to: 0.5; from: 0}
					//NumberAnimation { target: secondBackgroundDesktop; property: "opacity"; to: 1; from: 0}

					//onRunningChanged: {
					//	if (initAnim.running) {
					//		dashboard.height = dashboard.screenHeight;
					//		dashboard.width = dashboard.screenWidth;
					//	}
					//}
				}
				ParallelAnimation {
					id: endAnim
					NumberAnimation { target: dash; property: "y"; to: -dash.height}
					NumberAnimation { target: backgroundDarken; property: "opacity"; to: 0; from: 0.5}
					// Cheaper!
					//NumberAnimation { target: secondBackgroundDesktop; property: "opacity"; to: 0; from: 1}
					// Not so cheap, probably!
					NumberAnimation { target: blurBackground; property: "radius"; to: 1; from: 32}
					//NumberAnimation { target: dashboard; property: "opacity"; to: 0; from: dashboard.opacity}
					//NumberAnimation { target: dashboardBackground; property: "opacity"; to: 0; from: dashboard.opacity}
					//NumberAnimation { target: mainBackground; property: "opacity"; to: 0; from: mainBackground.opacity}
					//NumberAnimation { target: backgroundDarken; property: "opacity"; to: 0; from: backgroundDarken.opacity}

					onRunningChanged: {
						if (!endAnim.running) {
							dashboard.height = 0;
							dashboard.width = 0;
							//dashboard.visible = false;
						}
					}
				}

				ActivitiesContainer {
					// Instantiate our activity container.
					id: allActivities
				}

				Item {
				//PlasmaCore.Dialog {
					id: dashboardBackground
					//visible: true
					anchors.fill: dashboard
					height: dashboard.screenHeight
					width: dashboard.screenWidth
					//clip: true
					//blah: blah
					//property var model: ActivitySwitcher.Backend.runningActivitiesModel()
					property string background: { return allActivities.getCurrentBackground() }
					x: 0
					y: 0
					//z: 0
					//z: 100
					Image {
						id: firstBackgroundDesktop
						anchors.fill: dashboard
						smooth: true
						//clip: true
						//visible: true
						//source: "wallhaven-567367.jpg"
						//source: "image://wallpaperthumbnail/" + dashboardBackground.background
						fillMode: Image.PreserveAspectCrop
						source: dashboardBackground.background
						height: dashboard.screenHeight
						width: dashboard.screenWidth
						opacity: 1
						// Maybe?
						asynchronous: true
						cache: false
					}

					Image {
						id: secondBackgroundDesktop
						anchors.fill: dashboard
						smooth: true
						//clip: true
						//visible: true
						//source: "wallhaven-567367.jpg"
						//source: "image://wallpaperthumbnail/" + dashboardBackground.background
						fillMode: Image.PreserveAspectCrop
						source: dashboardBackground.background
						height: dashboard.screenHeight
						width: dashboard.screenWidth
						opacity: 0
						// Maybe?
						asynchronous: true
						cache: false
					}

					// Doesn't seem to like this.
					FastBlur {
						id: blurBackground
						anchors.fill: secondBackgroundDesktop
						source: secondBackgroundDesktop
						radius: 32
					}

					Rectangle {
						anchors.fill: dashboard
						id: backgroundDarken
						//visible: true
						opacity: 0.5
						//clip: true
						color: 'black'
						height: dashboard.screenHeight
						width: dashboard.screenWidth
					}
				//}

				// Here, we're going to build up the desktops and thumbnails.
				// For each entry here, we want nDesktops in the first row, and one in the second.
				Item {
					id: dash
					//visible: true
					opacity: 1

					// When y is set, we start this animation.  This gracefully moves the dock into position, ignoring the whole 'slide' thing.
					width: dashboard.screenWidth
					//height: main.screenHeight
					height: 100
					y: 0
					anchors.fill: dashboard
					//anchors.fill: parent

					Rectangle {
						opacity: 0.5
						//visible: dashboard.visible
						height: dash.height + 20
						width: dashboard.screenWidth
						color: 'black'
					}
					//  This is where we'll build up the grid.  I like to think, anyway.


					// This seems pretty nice, honestly.
					Flickable {
						id: desktopThumbnailGrid
						anchors.fill: parent

						property int spacing: 10
						height: dash.height
						contentHeight: desktopThumbnailGridBackgrounds.height
						contentWidth: desktopThumbnailGridBackgrounds.width
						//boundsMovement: Flickable.StopAtBounds
						//boundsBehavior: Flickable.DragAndOvershootBounds

						//visible: true
						y: 0
						// This is our active rectangle.  We shift it when our active desktop changes.
						Rectangle {
							id: activeDesktopIndicator
							// We just want this to stand out, currently.
							color: 'white'
							opacity: 1
							visible: true
							scale: 1
							clip: true
							//x: -2
							x: ((dash.height*dashboard.screenRatio+desktopThumbnailGrid.spacing)*(workspace.currentDesktop-1)) - 2
							y: 8
							//height: desktopThumbnailGridBackgrounds.height
							//width: desktopThumbnailGridBackgrounds.width
							height: desktopThumbnailGrid.height+4
							width: (dash.height*dashboard.screenRatio)+4
						}
						PropertyAnimation {
							id: activeDesktopIndicatorShiftAnim
							target: activeDesktopIndicator
							property: 'x'
							running: false
							property var originalX: 0
							property var newX: 0
							from: activeDesktopIndicatorShiftAnim.originalX
							to: activeDesktopIndicatorShiftAnim.newX
							duration: 1000
							//easing.type: Easing.OutBounce
						}
						Grid {
							// This is just for each of our desktops.
							//id: newRepeater
							id: desktopThumbnailGridBackgrounds
							rows: 1
							x: 0
							y: 10
							spacing: desktopThumbnailGrid.spacing
							//anchors.fill: parent

							columns: {
								if (workspace.desktops <= 6 ) {
									//desktopThumbnailGridBackgrounds.columns = 6;
									return 6;
								} else {
									//desktopThumbnailGridBackgrounds.columns = workspace.desktops;
									return workspace.desktops;
								}
							}
							Repeater {
								// Now, we build up our desktops.
								model: dashboard.returnNumberOfDesktops()
								id: littleDesktopRepeater
								Item {
									id: littleDesktopContainer
									visible: true
									property int desktop: model.index
									height: desktopThumbnailGrid.height
									width: dash.height*dashboard.screenRatio
									Image {
										//id: secondBackgroundDesktop
										//anchors.fill: dashboard
										//anchors.fill: parent
										//smooth: true
										// Better scaling
										mipmap: true
										//border { left: 30; top: 30; right: 30; bottom: 30 }
										//horizontalTileMode: BorderImage.Stretch
  									//verticalTileMode: BorderImage.Stretch
										//clip: true
										//visible: true
										//source: "wallhaven-567367.jpg"
										//source: "image://wallpaperthumbnail/" + dashboardBackground.background
										fillMode: Image.PreserveAspectCrop
										source: dashboardBackground.background
										//height: dashboard.screenHeight
										//width: dashboard.screenWidth
										height: desktopThumbnailGrid.height
										width: dash.height*dashboard.screenRatio
										x: 0
										y: 0
										// Maybe?
										//asynchronous: true
										//cache: false
									}

									  MouseArea {
									    id: littleDesktopGridMouseArea
									    anchors.fill: parent
									    //drag.axis: 'XAndYAxis'
									    //drag.target: kwinClientThumbnail
									    //hoverEnabled: true
									    onClicked: {
									      // We only want to disable the dashboard when we double click on the item
									      // or when we're currently on said desktop and are 'sure'.
									      if (littleDesktopContainer.desktop != workspace.currentDesktop-1) {
													workspace.currentDesktop = littleDesktopContainer.desktop+1;
									      } else {
														/*if (mainBackground.state == 'visible') {
															mainBackground.state = 'invisible';
														} else if (mainBackground.state == 'invisible') {
															mainBackground.state = 'visible';
														}*/
														toggleBoth();
												}
									    }
									  }
									Clients {
										//anchors.fill: parent
										id: littleDesktopGrid
										desktop: littleDesktopContainer.desktop
										x: dash.height*.025*dashboard.screenRatio
										y: dash.height*.025
										height: dash.height*.95
										width: dash.height*dashboard.screenRatio*.95
										//height: dashboard.screenHeight - dash.height - 30
										//width: dashboard.screenWidth
									}
								}
							}
						}
					}
				}
				// We'll create our normal desktop windows here with the same code.
				// Just a little bit of tinkering should work.

				// For the current desktop, build a grid.
				// Easy, but really quite slow.
				Item {
					id: currentDesktopGridThumbnailContainer
					//contentHeight: desktopThumbnailGridBackgrounds.height
					//contentWidth: desktopThumbnailGridBackgrounds.width
					//contentHeight: (dashboard.screenHeight - dash.height - 30)
					//contentWidth: dashboard.screenWidth
					//anchors.fill: parent
					Repeater {
						// Now, we build up our desktops.
						model: dashboard.returnNumberOfDesktops()
						id: currentDesktopGrid
						height: (dashboard.screenHeight - dash.height - 30)
						width: dashboard.screenWidth
						Item {
							id: bigDesktopRepeater
							//id: bigDesktopContainer
							visible: true
							property int desktop: model.index
							//height: dashboard.screenHeight - dash.height - 30
							//width: dashboard.screenWidth
							Clients {
								//id: currentDesktopGrid
								desktop: bigDesktopRepeater.desktop
								visible: false
								x: 0
								y: dash.height + 30
								scale: 1
								height: (dashboard.screenHeight - dash.height - 30)
								width: dashboard.screenWidth
								isMain: false
								isLarge: true
							}
						}
					}
			}
		}
	}
		Component.onCompleted: {
			dashboard.dockHeight = _getDockHeight();
			dashboard.activeScreen =  workspace.clientArea(KWinLib.MaximizedArea, workspace.activeScreen, workspace.currentDesktop);
			dashboard.screenWidth = dashboard.activeScreen.width;
			dashboard.screenHeight = dashboard.activeScreen.height + _getDockHeight();
			dashboard.screenRatio = dashboard.activeScreen.width/dashboard.activeScreen.height;
			dashboard.visible = true;
			mainBackground.state = 'visible';
			populateVisibleClients();

			// disable!

			// Try and register a shortcut, maybe.
			//console.log(Object.getOwnPropertyNames(workspace));
			if (KWin.registerShortcut) {
			KWin.registerShortcut("OVERVIEW: Show kwinOverview",
															"Show kwinOverview",
															"Meta+A",
															function() {
																toggleBoth()
															}
				);
			}
			// Make the big ones.
			height: dashboard.screenHeight - dash.height - 30
			width: dashboard.screenWidth
			CreateClients.createAllClientThumbnails(
				currentDesktopGridThumbnailContainer,
				dashboard,
				6,
				dashboard.screenHeight - dash.height - 30,
				dashboard.screenWidth,
				true
			)
			CreateClients.createAllClientThumbnails(
				desktopThumbnailGrid,
				dashboard,
				6,
				dash.height*.95,
				dash.height*dashboard.screenRatio*.95,
				false
			)
			// Make sure we add new thumbnails as necessary.
			workspace.clientAdded.connect(function (c) {
				console.log(c);
				CreateClients.createNewClientThumbnails(
					desktopThumbnailGrid,
					dashboard,
					6,
					dash.height*.95,
					dash.height*dashboard.screenRatio*.95,
					false,
					c
				);
				CreateClients.createNewClientThumbnails(
					currentDesktopGridThumbnailContainer,
					dashboard,
					6,
					dashboard.screenHeight - dash.height - 30,
					dashboard.screenWidth,
					true,
					c
				);
			});
			workspace.currentDesktopChanged.connect(function() {
				activeDesktopIndicatorShiftAnim.newX = ((dash.height*dashboard.screenRatio+desktopThumbnailGrid.spacing)*(workspace.currentDesktop-1)) - 2;
				activeDesktopIndicatorShiftAnim.originalX = activeDesktopIndicator.x;
				activeDesktopIndicatorShiftAnim.restart();
				// Move the flickable container.
				//if (((dash.height*dashboard.screenRatio+desktopThumbnailGrid.spacing)*(workspace.currentDesktop-1)) > desktopThumbnailGrid.contentY) {
				//	desktopThumbnailGrid.contentY = desktopThumbnailGrid.contentY + ((dash.height*dashboard.screenRatio+desktopThumbnailGrid.spacing));
				//}
			});
			toggleBoth();
			// Register all our clients.
			//var c;
			//for (c = 0; c < workspace.clientList().length; c++) {
			//	workspace.clientList()[c].desktopChanged.connect(checkGridUpdate);
			//}
		}

	function toggleBoth() {
		//console.log(Object.getOwnPropertyNames(workspace))
		// Okay, NOW this works.
		// but everything still sort of sucks.
		console.log('TESTING!');
		/*console.log(Object.getOwnPropertyNames(workspace));
		console.log(Object.getOwnPropertyNames(workspace.activities));
		console.log(Object.getOwnPropertyNames(workspace.activities[0]));
		console.log(JSON.stringify(workspace.activities[0]));
		console.log(workspace.activities[0]);
		console.log(JSON.stringify(workspace.clientList()[0]));
		console.log(Object.getOwnPropertyNames(workspace.clientList()[0]));
		console.log(Object.getOwnPropertyNames(workspace.clientList()[0].desktop));
		console.log(workspace.clientList()[0].desktop);*/
		//console.log(allActivities);
		//console.log(workspace.clientList()[0].isOnCurrentActivity);
		//console.log(JSON.stringify(workspace.clientList()[1]));
		console.log(Object.getOwnPropertyNames(desktopThumbnailGridBackgrounds));
		if (mainBackground.state == 'visible') {
			//dashboard.visible = false;
			//ndAnim.running = true;
			endAnim.restart();
			// For the moment, just pause.  We'll probably hook it up to a signal?
			//while (endAnim.busy == true) {};
			//dashboard.height = 0;
			//dashboard.width = 0;
			mainBackground.state = 'invisible';
			/*for (c = 0; c < currentDesktopGrid.itemAt(workspace.currentDesktop-1).children[0].children.length; c++) {
				//
				//console.log(Object.getOwnPropertyNames(currentDesktopGrid.children[0].children[c]));;
				currentDesktopGrid.itemAt(workspace.currentDesktop-1).children[0].children[0].children[c].startMoveFromThumbnail();
			}*/
			//enableVisibleClients();
			//endAnim
		} else if (mainBackground.state == 'invisible') {
			// It hates this command.  Straight up.  It seems to still be hiding things.
			//dashboard.visible = true;
			//dashboard.flags = Qt.X11BypassWindowManagerHint | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint // won't work without it, apparently.
			//dashboard.show();
			// Show, then run the init animation.
			//disableVisibleClients();
			dashboard.height = dashboard.screenHeight;
			dashboard.width = dashboard.screenWidth;
			//dashboard.visible = true;
			initAnim.restart();
			mainBackground.state = 'visible';
			//currentDesktopGrid.itemAt(workspace.currentDesktop-1).updateGrid();
			// Start the animation for the main grid.
			/*var c;
			for (c = 0; c < currentDesktopGrid.itemAt(workspace.currentDesktop-1).children[0].children.length; c++) {
				//
				currentDesktopGrid.itemAt(workspace.currentDesktop-1).children[0].children[c].startMoveToThumbnail();
			};*/
			//console.log(Object.getOwnPropertyNames(dashboard));
			//initAnim.running = true;
			//dashboard.update();
			//dashboard.raise();
		}
		//console.log('Which things are visible?');
		// Although they SAY that they're visible, they are not.
		// That is, I don't think they're being painted?  For some reason.
		//console.log(dashboard.visible);
		//console.log(mainBackground.visible);
		//console.log(dashboardBackground.visible);
		//console.log(Object.getOwnPropertyNames(workspace.currentDesktopChanged));
	}

	function populateVisibleClients() {
		// We need to build the list.
		var c;
		dashboard.clientsVisible = new Array(workspace.clientList().length);
		for (c = 0; c < workspace.clientList().length; c++) {
			//console.log(JSON.stringify(workspace.clientList()[c]));
			dashboard.clientsVisible[c] = workspace.clientList()[c].minimized;
	  }
	}

	function disableVisibleClients() {
		var c;
		for (c = 0; c < workspace.clientList().length; c++) {
			//workspace.clientList()[c].minimized = true;
			//workspace.clientList()[c].visible = false;
			//console.log(Object.getOwnPropertyNames(workspace.clientList()[c]));
			//console.log(Object.getOwnPropertyNames(workspace));
			// We're just hiding it by making it invisible.
			workspace.clientList()[c].opacity = 0;
		}
	}

	function returnNumberOfDesktops() {
		return workspace.desktops;
	}

	function enableVisibleClients() {
		var c;
		for (c = 0; c < workspace.clientList().length; c++) {
			if (dashboard.clientsVisible[c] == false) {
				//workspace.clientList()[c].minimized = false;
				// Better than hiding!
				workspace.clientList()[c].opacity = 1;
				//workspace.clientList()[c].showClient();
			}
		}
	}


}
