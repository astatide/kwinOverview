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
	Item {
		id: mainBackground
		anchors.fill: parent
		x: 0
		y: 0
		opacity: 1


		// This creates a mouseArea for the rectangle.  We change the height of our dock.
		MouseArea {
			anchors.fill: parent
			enabled: true
			onClicked: {
				//mainContainer.toggleBoth();
				dashboard.toggleBoth();
			}
		}

		// First, we create some states: visible, and otherwise.
		states: [
			State {
				name: 'visible'
			},
			State {
				name: 'invisible'
			}
		]
		NumberAnimation { id: fadeToBlack; running: false; alwaysRunToEnd: true; target: foregroundDarken; property: "opacity"; to: 1; from: 0}
		NumberAnimation { id: fadeFromBlack; running: false; alwaysRunToEnd: true; target: foregroundDarken; property: "opacity"; to: 0; from: 1}

		ActivitiesContainer {
			// Instantiate our activity container.
			id: allActivities
		}

		Item {
			id: dashboardBackground
			anchors.fill: parent
			property string background: { return allActivities.getCurrentBackground() }
			x: 0
			y: 0
			visible: true
			Image {
				id: firstBackgroundDesktop
				anchors.fill: parent
				smooth: true
				fillMode: Image.PreserveAspectCrop
				source: dashboardBackground.background
				height: dashboard.screenHeight
				width: dashboard.screenWidth
				opacity: 1
				asynchronous: true
				cache: false
				visible: false
			}

			Image {
				id: secondBackgroundDesktop
				anchors.fill: parent
				smooth: true
				fillMode: Image.PreserveAspectCrop
				source: dashboardBackground.background
				height: dashboard.screenHeight
				width: dashboard.screenWidth
				opacity: 0
				asynchronous: true
				cache: false
				visible: false

			}

			FastBlur {
				id: blurBackground
				anchors.fill: secondBackgroundDesktop
				source: secondBackgroundDesktop
				radius: 32
				visible: false

			}

			Rectangle {
				anchors.fill: parent
				id: backgroundDarken
				opacity: 0.5
				color: 'black'
				height: dashboard.screenHeight + dashboard.dockHeight
				width: dashboard.screenWidth
				visible: false

			}
			Flickable {
				id: currentDesktopGridThumbnailContainer
				anchors.fill: parent

				property int spacing: 10
				opacity: 1
				visible: true
				height: dashboard.screenHeight //- 220//(dashboardActivityChanger.height + dashboardDesktopChanger.height)*dashboard.scalingFactor
				width: dashboard.width
				contentHeight: dashboard.screenHeight //- 220//(dashboardActivityChanger.height + dashboardDesktopChanger.height)*dashboard.scalingFactor
				contentWidth: dashboard.width*workspace.desktops
				interactive: false

				y: 0
				x: 0
				// Aha, this is a pointer
				contentX: (workspace.currentDesktop-1) * (dashboard.screenWidth+spacing)
				Behavior on contentX {
					NumberAnimation {
						 duration: 250
						}
				}

				MouseArea {
					enabled: true
					id: flickTest
					anchors.fill: parent
					onClicked: {
						if (bigDesktopContainer.desktop != workspace.currentDesktop-1) {
							workspace.currentDesktop = bigDesktopContainer.desktop+1;
						} else {
								toggleBoth();
						}
					}
				}
				Grid {
					// This is just for each of our desktops.
					id: bigDesktopThumbnailGridBackgrounds
					visible: true
					rows: 1
					x: 0
					y: 0
					spacing: currentDesktopGridThumbnailContainer.spacing
					height: currentDesktopGridThumbnailContainer.height
					width: currentDesktopGridThumbnailContainer.width

					columns: {
							return workspace.desktops;
					}
					Repeater {
						// Now, we build up our desktops.
						model: workspace.desktops
						id: currentDesktopGrid
						Item {
							id: bigDesktopContainer
							visible: true
							property int desktop: model.index
							height: currentDesktopGridThumbnailContainer.height
							width: currentDesktopGridThumbnailContainer.width
								MouseArea {
									enabled: false
									id: bigDesktopGridMouseArea
									anchors.fill: parent
									onClicked: {
										if (bigDesktopContainer.desktop != workspace.currentDesktop-1) {
											workspace.currentDesktop = bigDesktopContainer.desktop+1;
										} else {
												toggleBoth();
										}
									}
								}
							Clients {
								//anchors.fill: parent
								id: bigDesktopClients
								desktop: bigDesktopContainer.desktop
								height: currentDesktopGridThumbnailContainer.height
								width: currentDesktopGridThumbnailContainer.width
								visible: false
								isLarge: true
							}
							// Can we use this?
							DropArea {
								id: bigDesktopDropArea
								anchors.fill: parent
								x: 0
								y: 0
								height: currentDesktopGridThumbnailContainer.height
								width: currentDesktopGridThumbnailContainer.width
								Rectangle {
									anchors.fill: parent
									visible: false
									color: "green"
									opacity: 0.5
								}
								onEntered: {
								}
								onExited: {
									drag.source.newDesktop = workspace.currentDesktop; //drag.source.currentDesktop;
								}
							}
						}
					}
				}
				Component.onCompleted: {
				}
		}
			Rectangle {
				id: foregroundDarken
				visible: true
				opacity: 0
				x: 0
				y: 0
				color: 'black'
				height: dashboard.screenHeight
				width: dashboard.screenWidth
			}
		}
	}
	Timer {
		id: timer
		interval: 200
		onTriggered: {
		}
	}

	Window {
		id: dashboardDesktopChanger
		flags: Qt.WA_TranslucentBackground | Qt.WA_OpaquePaintEvent | Qt.WindowMaximized | Qt.CustomizeWindowHint | Qt.WindowTitleHint | Qt.BypassGraphicsProxyWidget | Qt.WindowStaysOnTopHint | Qt.X11BypassWindowManagerHint
		color: '#00000000'
		visible: true
		title: "Yay"
		x: 0
		y: 0
		opacity: 1
		height: (100+20) * dashboard.scalingFactor
		width: dashboard.screenWidth

		Item {
			id: dash
			//visible: true
			opacity: 1

			// When y is set, we start this animation.  This gracefully moves the dock into position, ignoring the whole 'slide' thing.
			width: dashboard.screenWidth
			height: 120 * dashboard.scalingFactor
			property int gridHeight: 100 * dashboard.scalingFactor
			y: 0 //-120 * dashboard.scalingFactor


			PlasmaCore.Dialog {
				id: dashPlasmaBack
				visible: true
				opacity: 0.5
				y: 0
				x: 0
				flags: Qt.X11BypassWindowManagerHint
				Rectangle {
					opacity: 0
					visible: false
					height: dash.height - 10
					width: dashboard.screenWidth
					color: 'black'
					x: 0
					y: 0
				}
			}

			Flickable {
				id: desktopThumbnailGrid
				anchors.top: parent.top
				anchors.left: parent.left
				anchors.right: parent.right
				anchors.leftMargin: 5
				property int spacing: 10
				height: dash.gridHeight
				contentHeight: desktopThumbnailGridBackgrounds.height
				contentWidth: desktopThumbnailGridBackgrounds.width

				y: 0
				Rectangle {
					id: activeDesktopIndicator
					// We just want this to stand out, currently.
					color: 'white'
					opacity: 1
					visible: true
					scale: 1
					clip: true
					x: ((dash.gridHeight*dashboard.screenRatio+desktopThumbnailGrid.spacing)*(workspace.currentDesktop-1)) - 2
					y: 8
					height: desktopThumbnailGrid.height+4
					width: (dash.gridHeight*dashboard.screenRatio)+4
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
				}
				Grid {
					// This is just for each of our desktops.
					id: desktopThumbnailGridBackgrounds
					rows: 1
					x: 0
					y: 10
					spacing: desktopThumbnailGrid.spacing

					columns: {
						if (workspace.desktops <= 6 ) {
							return 6;
						} else {
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
							width: dash.gridHeight*dashboard.screenRatio
							Image {
								id: littleDesktopBackground
								mipmap: true
								fillMode: Image.PreserveAspectCrop
								source: dashboardBackground.background
								height: desktopThumbnailGrid.height
								width: dash.gridHeight*dashboard.screenRatio
								x: 0
								y: 0
							}
								MouseArea {
									id: littleDesktopGridMouseArea
									anchors.fill: parent
									hoverEnabled: true
									preventStealing: true
									onClicked: {
										if (littleDesktopContainer.desktop != workspace.currentDesktop-1) {
											workspace.currentDesktop = littleDesktopContainer.desktop+1;
										} else {
												toggleBoth();
										}
									}
									onEntered: {
										console.log('ENTERING!');
										dashboard.newDesktop = littleDesktopContainer.desktop+1;
									}
									onExited: {
										dashboard.newDesktop = -1;
									}
								}
							Clients {
								id: littleDesktopGrid
								desktop: littleDesktopContainer.desktop
								height: dash.gridHeight
								width: dash.gridHeight*dashboard.screenRatio
							}
							DropArea {
								id: littleDesktopDropArea
								anchors.fill: parent
								x: 0
								y: 0
								height: desktopThumbnailGrid.height
								width: dash.gridHeight*dashboard.screenRatio
								Rectangle {
									anchors.fill: parent
									visible: false
									color: "green"
								}
								onEntered: {
									console.log('ENTERING!');
									drag.source.newDesktop = littleDesktopContainer.desktop+1;
									console.log(drag.source.newDesktop);
								}
								onExited: {
									console.log('LEAVING');
									drag.source.newDesktop = workspace.currentDesktop; //drag.source.currentDesktop;
									console.log(drag.source.newDesktop);
								}
							}
						}
					}
				}
			}
			Item {
				id: dashAddRemoveDesktopButtons
				y: 0
				x: dashboard.screenWidth-50
				height: 120
				Rectangle {
					width: 50
					color: 'transparent'
					opacity: 0.5
					LinearGradient {
							anchors.fill: parent
							start: Qt.point(0, 0)
							end: Qt.point(25, 0)
							gradient: Gradient {
									GradientStop { position: 0.0; color: 'transparent' }
									GradientStop { position: 1.0; color: 'black' }
							}
					}
				}
				Rectangle {
					id: plusButton
					height: 55 * dashboard.scalingFactor
					width: 40 * dashboard.scalingFactor
					color: 'transparent'
					Text {
						id: actualPlusButton
						anchors.horizontalCenter: parent.horizontalCenter
						anchors.verticalCenter: parent.verticalCenter
						opacity: 1
						text: "+"
						font.pointSize: 25
						font.bold: true
						color: "white"
						y: 0
					}
					MouseArea {
						anchors.fill: parent
						id: plusButtonMouseArea
						onPressed: {
							actualPlusButton.color = 'grey';
						}
						onReleased: {
							actualPlusButton.color = 'white';
							if (workspace.desktops < 20) {
								workspace.desktops = workspace.desktops + 1;
							}
						}
					}
				}
				Rectangle {
					id: minusButton
					anchors.top: plusButton.bottom
					height: 55 * dashboard.scalingFactor
					width: 40 * dashboard.scalingFactor
					//color: 'white'
					y: 50
					color: 'transparent'
					Text {
						id: actualMinusButton
						anchors.horizontalCenter: parent.horizontalCenter
						anchors.verticalCenter: parent.verticalCenter
						opacity: 1
						text: "-"
						font.pointSize: 25
						font.bold: true
						color: "white"
						y: 0
					}
					MouseArea {
						anchors.fill: parent
						id: minusButtonMouseArea
						onPressed: {
							//console.log('yay');
							actualMinusButton.color = 'grey';
						}
						onReleased: {
							actualMinusButton.color = 'white';
							if (workspace.desktops > 1) {
								workspace.desktops = workspace.desktops - 1;
							}
						}
					}
				}
			}
		}
		Component.onCompleted: {
			populateVisibleClients();
			CreateClients.createAllClientThumbnails(
				currentDesktopGridThumbnailContainer,
				dashboard,
				6,
				dashboard.height,
				dashboard.width,
				true
			)
			CreateClients.createAllClientThumbnails(
				desktopThumbnailGrid,
				dashboard,
				6,
				dash.gridHeight*.95,
				dash.gridHeight*dashboard.screenRatio*.95,
				false
			)
			workspace.clientAdded.connect(function (c) {
				populateVisibleClients();
				CreateClients.createNewClientThumbnails(
					desktopThumbnailGrid,
					dashboard,
					6,
					dash.gridHeight*.95,
					dash.gridHeight*dashboard.screenRatio*.95,
					false,
					c
				);
				CreateClients.createNewClientThumbnails(
					currentDesktopGridThumbnailContainer,
					dashboard,
					6,
					dashboard.screenHeight - dash.gridHeight - 30,
					dashboard.screenWidth,
					true,
					c
				);
			});
			workspace.currentDesktopChanged.connect(function() {
				activeDesktopIndicatorShiftAnim.newX = ((dash.gridHeight*dashboard.screenRatio+desktopThumbnailGrid.spacing)*(workspace.currentDesktop-1)) - 2;
				activeDesktopIndicatorShiftAnim.originalX = activeDesktopIndicator.x;
				activeDesktopIndicatorShiftAnim.restart();
				if (mainBackground.state == 'visible') {
					timer.restart();
				}
			});
			var d;
			for (d = 0; d < workspace.desktops; d++) {
			}
			toggleBoth();
			toggleBoth();
		}
		function populateVisibleClients() {
			// We need to build the list.
			console.log('POPULATIONG CLIENTS');
			var c;
			dashboard.clientsVisible = new Array(workspace.clientList().length);
			for (c = 0; c < workspace.clientList().length; c++) {
				dashboard.clientsVisible[c] = workspace.clientList()[c].minimized;
			}
		}

		function disableVisibleClients() {
			var c;
			for (c = 0; c < workspace.clientList().length; c++) {
				workspace.clientList()[c].opacity = 0;
				workspace.clientList()[c].oldNoBorder = workspace.clientList()[c].noBorder;
				workspace.clientList()[c].noBorder = true;

			}
		}
		function enableVisibleClients() {
			var c;
			for (c = 0; c < workspace.clientList().length; c++) {
				if (dashboard.clientsVisible[c] == false) {
					// Better than hiding!
					workspace.clientList()[c].opacity = 1;
					workspace.clientList()[c].noBorder = workspace.clientList()[c].oldNoBorder;

				}
			}
		}


	}
	Window {
			id: dashboardActivityChanger
			opacity: 1
			flags: Qt.WA_TranslucentBackground | Qt.WA_OpaquePaintEvent | Qt.FramelessWindowHint | Qt.WindowMaximized | Qt.CustomizeWindowHint | Qt.WindowTitleHint | Qt.BypassGraphicsProxyWidget | Qt.WindowStaysOnTopHint | Qt.X11BypassWindowManagerHint
			color: '#00000000'
			visible: true
			x: 0
			y: dashboard.screenHeight //- (100*dashboard.scalingFactor)
			height: 100 * dashboard.scalingFactor
			width: dashboard.screenWidth
			Item {
				id: activitySwitcherDash
				x: 0
				width: dashboard.screenWidth
				scale: 1
				height: 100 * dashboard.scalingFactor
				y: 0 //100 * dashboard.scalingFactor
				property int gridHeight: 80 * dashboard.scalingFactor
				NumberAnimation {
					id: showActivitySwitcherDashAnim
					running: false
					target: activitySwitcherDash
					property: "y"
					to: dashboard.screenHeight - activitySwitcherDash.height
				}
				NumberAnimation {
					id: hideActivitySwitcherDashAnim
					running: false
					target: activitySwitcherDash
					property: "y"
					to: dashboard.screenHeight - 20
				}
				Timer {
					id: activitySwitcherDashTimer
					interval: 500
					onTriggered: {
					}
				}
				PlasmaCore.Dialog {
					id: activitySwitcherPlasmaBack
					visible: true
					opacity: 0.5
					y: dashboard.screenHeight
					x: 0
					flags: Qt.X11BypassWindowManagerHint
					Rectangle {
						opacity: 0
						visible: false
						height: activitySwitcherDash.height
						width: dashboard.screenWidth
						color: 'black'
						x: 0
						y: 0
					}
				}
				Rectangle {
					id: activitySwitcherDashBackground
					visible: false
					scale: 1
					opacity: 0.80
					y: 0
					x: 0
					height: activitySwitcherDash.height
					width: dashboard.screenWidth
					color: '#282828'
				}
				MouseArea {
					id: activitySwitcherDashMouseArea
					anchors.fill: parent
					enabled: true
					hoverEnabled: true
					onEntered: {
					}
					onExited: {
						activitySwitcherDashTimer.restart();
					}
				}
				Grid {
					id: activitySwitcherRepeaterGrid
					anchors.fill: parent
					anchors.verticalCenter: parent.verticalCenter
					anchors.horizontalCenter: parent.horizontalCenter
					anchors.topMargin: 10 * dashboard.scalingFactor
					anchors.leftMargin: desktopThumbnailGrid.spacing
					rows: 1
					columns:  10
					spacing: desktopThumbnailGrid.spacing
					visible: true
					Repeater {
						id: activitySwitcherRepeater
						model: ActivitySwitcher.Backend.runningActivitiesModel()
						Item {
							x: 0
							y: 0
							visible: true
							height: activitySwitcherDash.gridHeight
							width: activitySwitcherDash.gridHeight*dashboard.screenRatio
							Image {
								id: activityThumbnail
								anchors.fill: parent
								mipmap: true
								fillMode: Image.PreserveAspectCrop
								source: model.background
								opacity: 1
								asynchronous: true
								cache: false
							}
							Rectangle {
								id: activityThumbnailBlackRectangle
								scale: 1
								opacity: 0
								anchors.top: activityThumbnail.top
								height: activityThumbnail.height
								width: activityThumbnail.width
								color: 'black'
							}
							Text {
								id: activityThumbnailTitleText
								anchors.horizontalCenter: activityThumbnail.horizontalCenter
								anchors.verticalCenter: activityThumbnailBlackRectangle.verticalCenter
								anchors.topMargin: 2
								opacity: 0
								text: model.name
								font.bold: true
								color: "white"
							}
							ParallelAnimation {
								id: thumbnailHoverStart
								running: false
								NumberAnimation {
									target: activityThumbnailBlackRectangle;
									property: 'opacity';
									from: 0;
									to: 0.5;
								}
								NumberAnimation {
									target: activityThumbnailTitleText;
									property: 'opacity';
									from: 0;
									to: 1;
								}
							}
							ParallelAnimation {
								id: thumbnailHoverEnd
								running: false
								PropertyAnimation { target: activityThumbnailBlackRectangle; property: 'opacity'; to: 0; from: 0.5}
								PropertyAnimation { target: activityThumbnailTitleText; property: 'opacity'; to: 0; from: 1}
							}
							MouseArea {
								anchors.fill: parent
								enabled: true
								hoverEnabled: true
								onClicked: {
									fadeToBlack.restart();
									ActivitySwitcher.Backend.setCurrentActivity(model.id)
									fadeFromBlack.restart();
								}
								onEntered: {
									activitySwitcherDashTimer.stop();
									thumbnailHoverStart.restart();
								}
								onExited: {
									thumbnailHoverEnd.restart();
								}
							}
							// In case I ever figure out how to control the activities
							// flag of the clients from here.
							DropArea {
								id: activityDropArea
								anchors.fill: parent
								onEntered: {
									console.log('ENTERING ACTIVITY!');
									drag.source.newActivity = model.id;
								}
								onExited: {
									console.log('LEAVING ACTIVITY');
									drag.source.newActivity = drag.source.clientObject.activities;
								}
							}
						}
					}
				}
			}
		}
		function toggleBoth() {
			dashboardDesktopChanger.populateVisibleClients();
			if (mainBackground.state == 'visible') {
				endAnim.restart();
				dashboardDesktopChanger.enableVisibleClients();
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
			NumberAnimation { target: dashboardDesktopChanger; property: "y"; from: -dash.height*dashboard.scalingFactor; to: 0}
			NumberAnimation { target: dashPlasmaBack; property: "y"; from: -dash.height*dashboard.scalingFactor; to: 0}
			NumberAnimation { target: dashboardActivityChanger; property: "y"; from: dashboard.screenHeight; to: dashboard.screenHeight - (100*dashboard.scalingFactor)}
			NumberAnimation { target: activitySwitcherPlasmaBack; property: "y"; from: dashboard.screenHeight; to: dashboard.screenHeight - (100*dashboard.scalingFactor)}
			NumberAnimation { target: dashboard; property: "opacity"; to: 1; from: 0}
			// Expensive!
			SequentialAnimation {
				ParallelAnimation {
					NumberAnimation { target: blurBackground; property: "radius"; to: 32; from: 1}
					NumberAnimation { target: backgroundDarken; property: "opacity"; to: 0.5; from: 0}
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
					NumberAnimation { target: dashboardDesktopChanger; property: "y"; to: -dash.height*dashboard.scalingFactor; duration: 100}
					NumberAnimation { target: dashPlasmaBack; property: "y"; to: -dash.height*dashboard.scalingFactor; duration: 100}
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
			currentDesktopGridThumbnailContainer.state = 'showDesktop';

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
