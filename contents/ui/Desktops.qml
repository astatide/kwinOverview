import QtQuick 2.12
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

Item {
    id: desktopContainer
    visible: true
    property int desktop: model.index
    property string background: { return allActivities.getCurrentBackground() }
    height: 100
    property var screenRatio: 1
    width: height * screenRatio
    property bool showClients: true
    Image {
        id: desktopBackground
        mipmap: true
        fillMode: Image.PreserveAspectCrop
        source: desktopContainer.background
        height: desktopContainer.height
        width: desktopContainer.width
        x: 0
        y: 0
    }
    MouseArea {
        id: desktopGridMouseArea
        anchors.fill: parent
        hoverEnabled: true
        preventStealing: true
        propagateComposedEvents: true
        onClicked: {
            if (desktopContainer.desktop != workspace.currentDesktop-1) {
                workspace.currentDesktop = desktopContainer.desktop+1;
            } else {
                mouse.accepted = false;
                //toggleBoth();
            }
        }
        onPressed: {
            if (desktopContainer.desktop != workspace.currentDesktop-1) {
                workspace.currentDesktop = desktopContainer.desktop+1;
            } else {
                mouse.accepted = false;
                //toggleBoth();
            }
        }
        onEntered: {
            console.log('ENTERING MOUSE!');
            dashboard.newDesktop = desktopContainer.desktop+1;
        }
        onExited: {
            console.log('EXITING MOUSE!')
            dashboard.newDesktop = -1;
        }
    }
    Clients {
        id: desktopGrid
        desktop: desktopContainer.desktop
        height: desktopContainer.height * 0.95
        width: desktopContainer.width * 0.95
        visible: showClients
    }

    onShowClientsChanged: {
      desktopGrid.visible = showClients;
    }

    DropArea {
        id: desktopDropArea
        anchors.fill: desktopContainer
        x: 0
        y: 0
        height: desktopContainer.height
        width: height * desktopContainer.screenRatio
        Rectangle {
            anchors.fill: parent
            visible: false
            color: "green"
        }
        onEntered: {
            console.log('ENTERING!');
            console.log(desktopGrid.children[0]);
            drag.source.newDesktop = desktopContainer.desktop+1;
            console.log(drag.source.newDesktop);
        }
        onExited: {
            console.log('LEAVING');
            drag.source.newDesktop = workspace.currentDesktop; //drag.source.currentDesktop;
            console.log(drag.source.newDesktop);
        }
        onDropped: {
            console.log('DROPPED!');
            console.log(drop.source);
            drop.source.client.desktop = desktopContainer.desktop + 1;
            drop.source.desktop = desktopContainer.desktop;
            drop.source.parent = desktopGrid.children[0];
            console.log(desktopGrid.children[0]);
            console.log(drop.source.parent);
        }
    }
}