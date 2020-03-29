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