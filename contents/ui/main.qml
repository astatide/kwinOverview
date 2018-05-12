import QtQuick 2.2
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
			property int dockHeight: { return _getDockHeight() }
			property var activeScreen: { workspace.clientArea(KWinLib.MaximizedArea, workspace.activeScreen, workspace.currentDesktop) }
			//property var activeScreen: { workspace.clientArea(MaximizedArea, workspace.activeScreen, workspace.currentDesktop) }
			property int screenWidth: { activeScreen.width }
			property int screenHeight: { return activeScreen.height + _getDockHeight() }
			property var screenRatio: { activeScreen.width/activeScreen.height }

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
					onClicked: {
						if (mainBackground.state == 'visible') {
							//endAnim.running = true;
							//dashboardBackground.visible = false;
							//dashboard.visible = false;
							mainBackground.state = 'invisible';
						} else if (mainBackground.state == 'invisible') {
							//initAnim.running = true;
							//dashboardBackground.visible = true;
							//dashboard.visible = true;
							mainBackground.state = 'visible';
						}
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


					Item {
						id: desktopThumbnailGrid
						anchors.fill: parent

						property int spacing: 10
						height: dash.height

						//visible: true
						y: 0
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
									model: workspace.desktops
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
											anchors.fill: parent
											smooth: true
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

								//x: {
								//	if (workspace.desktops <= 6 ) {
								//		return width/6 + dash.height*dashboard.screenRatio
								//	} else {
								//		return width/(workspace.desktops) + dash.height*dashboard.screenRatio
								//	}
								//}

								/*Repeater {
									// Now, we build up our desktops.
									model: workspace.desktops
									Desktops {
										// I guess we can't refer to it by id anymore.
										background: newRepeater.background
										activityId: newRepeater.activityId
										desktop: model.index
										activityModel: newRepeater.activityModel
										isCurrent: newRepeater.isCurrent
										nClients: workspace.clientList().length
										x: 0
										y: 0
										height: desktopThumbnailGrid.height
										width: dash.height*dashboard.screenRatio
									}
								}*/
							}
					}
				}
				// We'll create our normal desktop windows here with the same code.
				// Just a little bit of tinkering should work.

				// For the current desktop, build a grid.
				// Easy, but really quite slow.
				Clients {
					//anchors.fill: parent
					id: currentDesktopGrid
					// I guess we can't refer to it by id anymore.
					//background: newRepeater.background
					//activityId: newRepeater.activityId
					desktop: workspace.currentDesktop-1
					//activityModel: newRepeater.activityModel
					//isCurrent: newRepeater.isCurrent
					//isCurrent: true
					//nClients: workspace.clientList().length
					x: 0
					y: dash.height + 30
					scale: 1
					//y: 0
					height: dashboard.screenHeight - dash.height - 30
					//width: (dashboard.screenHeight - dash.height - 30)*dashboard.screenRatio
					//width: dashboard.screenWidth
					//height: dashboard.screenHeight
					width: dashboard.screenWidth
					isMain: true
				}
		}
	}
		Component.onCompleted: {
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
			toggleBoth();
			// Register all our clients.
			//var c;
			//for (c = 0; c < workspace.clientList().length; c++) {
			//	workspace.clientList()[c].desktopChanged.connect(checkGridUpdate);
			//}
		}

		function checkGridUpdate() {
			// Not sure we can determine who sent the signal, actually,
			// so just update whenever a desktop change happens.
			currentDesktopGrid.updateGrid();
			// Let's update all the child grids, as well.
			//littleDesktopGrid.updateGrid();
			var d;
			for (d = 0; d < workspace.desktops; d++) {
				//console.log(Object.getOwnPropertyNames(littleDesktopRepeater.itemAt(d).children));
				// child 1 is the grid.
				littleDesktopRepeater.itemAt(d).children[1].updateGrid();
			}
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
		console.log(JSON.stringify(workspace.clientList()[1]));
		if (mainBackground.state == 'visible') {
			//dashboard.visible = false;
			//ndAnim.running = true;
			endAnim.restart();
			// For the moment, just pause.  We'll probably hook it up to a signal?
			//while (endAnim.busy == true) {};
			//dashboard.height = 0;
			//dashboard.width = 0;
			mainBackground.state = 'invisible';
			for (c = 0; c < currentDesktopGrid.children[0].children.length; c++) {
				//
				//console.log(Object.getOwnPropertyNames(currentDesktopGrid.children[0].children[c]));;
				currentDesktopGrid.children[0].children[c].startMoveFromThumbnail();
			};
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
			initAnim.restart();
			mainBackground.state = 'visible';
			currentDesktopGrid.updateGrid();
			// Start the animation for the main grid.
			var c;
			for (c = 0; c < currentDesktopGrid.children[0].children.length; c++) {
				//
				currentDesktopGrid.children[0].children[c].startMoveToThumbnail();
			};
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
