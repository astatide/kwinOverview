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
    id: desktopChanger
    flags: Qt.WA_TranslucentBackground | Qt.WA_OpaquePaintEvent | Qt.WindowMaximized | Qt.CustomizeWindowHint | Qt.WindowTitleHint | Qt.BypassGraphicsProxyWidget | Qt.WindowStaysOnTopHint | Qt.X11BypassWindowManagerHint
    property int border: 10
    property var screenRatio: 16/9
    property string background: { return allActivities.getCurrentBackground() }
    color: '#00000000'
    visible: true
    title: "Yay"
    x: 0
    y: 0
    opacity: 1
    height: (100+border) * dashboard.scalingFactor
    width: dashboard.screenWidth

    Item {
        id: dash
        //visible: true
        opacity: 1

        // When y is set, we start this animation.  This gracefully moves the dock into position, ignoring the whole 'slide' thing.
        width: parent.width
        height: parent.height
        property int gridHeight: (desktopChanger.height - 2*desktopChanger.border)
        y: 0 //-120 * dashboard.scalingFactor

        Rectangle {
            id: dashPlasmaBack
            opacity: 0
            visible: true
            // Basically, without this, Plasma just... doesn't show up, since it's "empty", I guess.
            height: desktopChanger.height
            width: desktopChanger.width
            //anchors.fill: desktopChanger
            color: 'black'
            y: desktopChanger.y
            x: desktopChanger.x
            PlasmaCore.Dialog {
                visible: true
                opacity: 0.5
                y: desktopChanger.y
                x: desktopChanger.x
                flags: Qt.X11BypassWindowManagerHint
                height: dashPlasmaBack.height
                width: dashPlasmaBack.width
                //anchors.fill: parent
                Rectangle {
                    visible: false
                    height: desktopChanger.height
                    width: desktopChanger.width
                }
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
                    // from Desktops.qml
                    Desktops {
                        id: littleDesktopContainer
                        height: desktopChanger.height - desktopChanger.border
                        screenRatio: desktopChanger.screenRatio
                        background: desktopChanger.background
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
        //CreateClients.createAllClientThumbnails(
        //    desktopThumbnailGrid,
        //    dashboard,
        //    6,
        //    dash.gridHeight*.95,
        //    dash.gridHeight*dashboard.screenRatio*.95,
        //    false
        //)
        //workspace.clientAdded.connect(function (c) {
        //    populateVisibleClients();
        //    CreateClients.createNewClientThumbnails(
        //        desktopThumbnailGrid,
        //        dashboard,
        //        6,
        //        dash.gridHeight*.95,
        //        dash.gridHeight*dashboard.screenRatio*.95,
        //        false,
         //       c
        //    );
        //});
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
        console.log('POPULATING CLIENTS');
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
                //workspace.clientList()[c].noBorder = workspace.clientList()[c].oldNoBorder;

            }
        }
    }


}