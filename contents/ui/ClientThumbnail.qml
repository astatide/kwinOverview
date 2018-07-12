import QtQuick 2.2
import org.kde.kwin 2.0 as KWinLib
//import org.kde.kwin 2.0;
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as Plasma

// Trying to get the image provider to work.
import org.kde.activities.settings 0.1
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

import org.kde.kquickcontrolsaddons 2.0 as KQuickControlsAddonsComponents

import org.kde.plasma.activityswitcher 1.0 as ActivitySwitcher

import org.kde.activities 0.1 as Activities

Item {
  id: kwinClientThumbnail
  visible: true
  // We need to dynamically set these.
  //property int originalWidth: kwinDesktopThumbnailContainer.width / clientGridLayout.columns
  //property int originalHeight: kwinDesktopThumbnailContainer.height / clientGridLayout.columns
  property int originalWidth: 0
  property int originalHeight: 0
  // This seems to be necessary to set everything appropriately.  Not 100% sure why.
  property int scale: 1
  property var originalParent: parent
  // Setting the height/width seems to break EVERYTHING, as the thumbnails are busted.
  //width: kwinDesktopThumbnailContainer.width / clientGridLayout.columns
  //height: kwinDesktopThumbnailContainer.height / clientGridLayout.columns
  // Get our actual client information.  This way, we can move through desktops/activities.
  property var clientObject: ''
  property var clientId: 0
  property var currentDesktop: 0
  property var newDesktop: 0
  property var newActivity: 0
  Drag.active: mouseArea.drag.active
  //Drag.hotSpot: Qt.point(50,50)

  // Ha ha!
  opacity: 1

  // This is for moving the thumbnail back
  property int originalX: 0
  property int originalY: 0
  // This is for moving to our thumbnail position and size.
  property int clientRealX: 0
  property int clientRealY: 0
  property int clientRealWidth: 0
  property int clientRealHeight: 0
  x: 0
  y: 0
  property bool isSmall: false
  property bool isLarge: false

  // For the mouse.
  //property QtObject container

  states: [
    State {
      name: 'isHeld'
      PropertyChanges {
        target: kwinClientThumbnail
        //parent: mainBackground
        //z: 10000
      }
    },
    State {
      name: 'notHeld'
      PropertyChanges {
        target: kwinClientThumbnail
        //z: 0
        //parent: clientGridLayout
      }
    }
  ]

  Item {
    id: actualThumbnail
    //anchors.fill kwinClientThumbnail
    height: kwinClientThumbnail.height
    width: kwinClientThumbnail.width
    visible: false
    opacity: 1
    /*Rectangle {
      //id: thumbnailBackgroundRectangle
      // This is a test rectangle.  Ultimately, I'd like to show this when compositing is off.
      anchors.fill: parent
      //anchors.fill kwinClientThumbnail
      color: 'black'
      opacity: 0.5
      visible: true
      scale: 1
      clip: true
      //x: 0
      //y: 0
      //height: kwinClientThumbnail.height
      //width: kwinClientThumbnail.width
      // Are THESE breaking it?  What the shit.
      // These DO seem to break it!  What the fuck.
      // Something about the way they're painted, maybe?  Not so good.
      // I think this is actually quite slow, but it's hard to say.  Can I speed it up?
    }*/
    KWinLib.ThumbnailItem {
      // Basically, this 'fills up' to the parent object, so we encapsulate it
      // so that we can shrink the thumbnail without messing with the grid itself.
      id: kwinThumbnailRenderWindow
      anchors.fill: actualThumbnail
      //wId: workspace.clientList()[clientId].windowId
      wId: kwinClientThumbnail.clientId
      //height: kwinClientThumbnail.height
      //width: kwinClientThumbnail.width
      x: 0
      y: 0
      z: 0
      visible: false
      clip: false
    }
  }

  ParallelAnimation {
    id: returnAnim
    NumberAnimation { target: kwinClientThumbnail; property: "x"; from: x; to: kwinClientThumbnail.originalX}
    NumberAnimation { target: kwinClientThumbnail; property: "y"; from: y; to: kwinClientThumbnail.originalY}
  }

  ParallelAnimation {
    id: shrinkAnim
    alwaysRunToEnd: false
    running: false
    property int animX: 0
    property int animY: 0

    PropertyAnimation {
      target: actualThumbnail
      //target: kwinClientThumbnail
      property: "height"
      to: 100*dash.scale
      duration: 100
    }
    PropertyAnimation {
      target: actualThumbnail
      //target: kwinClientThumbnail
      property: "width"
      to: 100*dashboard.screenRatio*dash.scale
      duration: 100
  }

    PropertyAnimation { target: actualThumbnail; property: "x"; to: shrinkAnim.animX-(dash.gridHeight/2*dashboard.screenRatio); duration: 100}
    PropertyAnimation { target: actualThumbnail; property: "y"; to: shrinkAnim.animY-dash.gridHeight/2; duration: 100}
    //PropertyAnimation { target: kwinClientThumbnail; property: "x"; to: shrinkAnim.animX-(dash.gridHeight/2*dashboard.screenRatio); duration: 100}
    //PropertyAnimation { target: kwinClientThumbnail; property: "y"; to: shrinkAnim.animY-dash.gridHeight/2; duration: 100}
    //PropertyAnimation { target: kwinClientThumbnail; property: "x"; to: kwinClientThumbnail.x-shrinkAnim.animX; duration: 100}
    //PropertyAnimation { target: kwinClientThumbnail; property: "y"; to: kwinClientThumbnail.y-shrinkAnim.animY; duration: 100}

    onStopped: {
      mouseArea.enabled = true;
      kwinClientThumbnail.isSmall = true;
      //x = x+originalWidth/2;
      //y = y+originalHeight/2;
    }
  }
  ParallelAnimation {
    id: growthAnim
    alwaysRunToEnd: false
    running: false
    property int animX: 0
    property int animY: 0
    PropertyAnimation { target: actualThumbnail; property: "height"; to: originalHeight; duration: 100}
    PropertyAnimation { target: actualThumbnail; property: "width"; to: originalWidth; duration: 100}
    PropertyAnimation { target: actualThumbnail; property: "x"; to: 0; duration: 100}
    PropertyAnimation { target: actualThumbnail; property: "y"; to: 0; duration: 100}


    onStopped: {
      mouseArea.enabled = true;
      kwinClientThumbnail.isSmall = false;
    }
  }
  ParallelAnimation {
    id: moveAnim
    alwaysRunToEnd: false
    running: false
    property int animX: 0
    property int animY: 0
    PropertyAnimation { target: kwinClientThumbnail; property: "y"; to: moveAnim.animY; duration: 128; easing.amplitude: 2; easing.type: Easing.InOutQuad;}
    PropertyAnimation { target: kwinClientThumbnail; property: "x"; to: moveAnim.animX; duration: 128; easing.amplitude: 2; easing.type: Easing.InOutQuad;}
    onStopped: {
      mouseArea.enabled = true;
      //kwinClientThumbnail.isSmall = false;
    }
  }
  ParallelAnimation {
    id: initMoveAnim
    alwaysRunToEnd: false
    running: false
    property int animX: 0
    property int animY: 0
    PropertyAnimation { target: kwinClientThumbnail; property: "y"; to: moveAnim.animY; duration: 100; easing.amplitude: 2; easing.type: Easing.InOutQuad;}
    PropertyAnimation { target: kwinClientThumbnail; property: "x"; to: moveAnim.animX; duration: 100; easing.amplitude: 2; easing.type: Easing.InOutQuad;}
    onStopped: {
      mouseArea.enabled = true;
      //kwinClientThumbnail.isSmall = false;
    }
  }

  MouseArea {
    id: mouseArea
    anchors.fill: parent
    drag.axis: 'XAndYAxis'
    drag.target: kwinClientThumbnail
    //drag.active: true
    hoverEnabled: true
    property bool dragActive: drag.active
    onClicked: {
      // We only want to disable the dashboard when we double click on the item
      // or when we're currently on said desktop and are 'sure'.
      if (kwinClientThumbnail.clientObject.desktop == workspace.currentDesktop) {
        dashboard.toggleBoth();
      } //else {
        //workspace.currentDesktop
      //}
      workspace.activeClient = clientObject;
    }

    onPositionChanged: {
      // Let's do this proper.
      shrinkAnim.animX = mouse.x;
      shrinkAnim.animY = mouse.y;
      growthAnim.animX = mouse.x;
      growthAnim.animY = mouse.y;
      if (kwinClientThumbnail.state == 'isHeld') {
        if (kwinClientThumbnail.isSmall == false) {
          shrinkAnim.start();
        }
      }
    }

    onPressed: {
      // Sets things up for the return animation.
      kwinClientThumbnail.originalX = kwinClientThumbnail.x;
      kwinClientThumbnail.originalY = kwinClientThumbnail.y;
      kwinClientThumbnail.clientObject.keepAbove = true;
      kwinClientThumbnail.state = 'isHeld';
      // This works!
      kwinClientThumbnail.Drag.hotSpot.x = mouse.x;
      kwinClientThumbnail.Drag.hotSpot.y = mouse.y;
      kwinClientThumbnail.newDesktop = kwinClientThumbnail.currentDesktop;
      kwinClientThumbnail.currentDesktop = kwinClientThumbnail.newDesktop;
    }
    onReleased: {
      kwinClientThumbnail.state = 'notHeld';
      kwinClientThumbnail.clientObject.keepAbove = false;
      //console.log(Drag.drop());
      //console.log('TESTING');
      //console.log(kwinClientThumbnail.newDesktop);
      //console.log(kwinClientThumbnail.newActivity);
      // Let's see if the dropArea can handle this.
      //var newDesktop = _overlapsDesktop(kwinClientThumbnail.mapToGlobal(mouse.x, mouse.y).x, kwinClientThumbnail.mapToGlobal(mouse.x, mouse.y).y);
      //var newDesktop = 0;
      //growthAnim.animX = kwinClientThumbnail.mapToGlobal(mouseX, mouseY).x;
      //growthAnim.animY = kwinClientThumbnail.mapToGlobal(mouseX, mouseY).y;
      if (kwinClientThumbnail.isSmall) {
        //growthAnim.running = true;
        growthAnim.restart();
        kwinClientThumbnail.isSmall = false;
      }
      if (kwinClientThumbnail.clientObject.activities != kwinClientThumbnail.newActivity) {
        //kwinClientThumbnail.clientObject.setActivity(kwinClientThumbnail.newActivity);
        // This is a read-only property, and so we're unable to change it from here.
        // Not sure if there's a model out there that would let us do it.
        //console.log(Object.getOwnPropertyNames(kwinClientThumbnail.clientObject));
        //kwinClientThumbnail.clientObject.activities = kwinClientThumbnail.newActivity;
        // for now, since we can't sort it.
        //var activityModel = console.log(Object.getOwnPropertyNames(Activities.ResourceInstance));
        //console.log(kwinClientThumbnail.clientObject.activities);
        returnAnim.running = true;
      } else if (kwinClientThumbnail.currentDesktop == kwinClientThumbnail.newDesktop ) {
        //console.log(newDesktop);
        returnAnim.running = true;
        //growthAnim.running = true;
        //kwinClientThumbnail.client
      } else if (kwinClientThumbnail.newDesktop == 0) {
        returnAnim.running = true;
        //growthAnim.running = true;
      } else {
        kwinClientThumbnail.currentDesktop = kwinClientThumbnail.newDesktop;
        kwinClientThumbnail.clientObject.desktop = kwinClientThumbnail.newDesktop;
        // We need to make it invisible, as well.
        //kwinClientThumbnail.visible = false;
        returnAnim.running = true;
        //kwinClientThumbnail.z = kwinClientThumbnail.originalZ;
        // We want the others to pop up, so.
      }
    }
  }

  Component.onCompleted: {
    // We just check to see whether we're on the current desktop.
    // If not, don't show it.
    growthAnim.running = false;
    shrinkAnim.running = false;
    clientObject.desktopChanged.connect(callUpdateGrid);
    clientObject.activitiesChanged.connect(callUpdateGrid);
    // It seems that occasionally, this might not fire off.  Unsure as to why.
    workspace.currentActivityChanged.connect(callUpdateGrid);
    mainBackground.onStateChanged.connect(toggleVisible);
    // We just need to make sure we're calling correct parent signals when
    // the desktop changes.  This avoids crashes upon creating/removing new desktops!
    workspace.numberDesktopsChanged.connect(callUpdateGrid);
    workspace.clientRemoved.connect(disconnectAllSignals);
    /*parent.onStateChanged.connect(function() {
      if (parent.isMain == true) {
        toggleVisible('visible');
      } else {
        toggleVisible('invisible');
      }
    });*/
    callUpdateGrid();
    searchFieldAndResults.children[1].forceActiveFocus();
  }

  function disconnectAllSignals(c) {
    //console.log(c);
    if (c) {
      if (c.windowId == kwinClientThumbnail.clientId) {
        //console.log('KILLING MYSELF');
        // Yes, we even have to disconnect this.
        workspace.clientRemoved.disconnect(disconnectAllSignals);
        workspace.numberDesktopsChanged.disconnect(callUpdateGrid);
        mainBackground.onStateChanged.disconnect(toggleVisible);
        clientObject.desktopChanged.disconnect(callUpdateGrid);
        clientObject.activitiesChanged.disconnect(callUpdateGrid);
        workspace.currentActivityChanged.disconnect(callUpdateGrid);
        kwinClientThumbnail.destroy();
      }
    }
  }


  function toggleVisible(state) {
    if (state == 'visible') {
      // only toggle the ones on the current activity.
      if (kwinClientThumbnail.clientObject.activities == workspace.currentActivity || kwinClientThumbnail.clientObject.activities == '') {
        kwinThumbnailRenderWindow.wId = kwinClientThumbnail.clientId;
        //kwinThumbnailRenderWindow.wId = -1;
        actualThumbnail.visible = true;
        kwinThumbnailRenderWindow.visible = true;
        kwinThumbnailRenderWindow.enabled = true;
        kwinClientThumbnail.visible = true;
      }
    } else if (state == 'invisible') {
    //} else {
      // break it for now.
      kwinThumbnailRenderWindow.wId = -1;
      actualThumbnail.visible = false;
      kwinThumbnailRenderWindow.visible = false;
      kwinThumbnailRenderWindow.enabled = false;
      kwinClientThumbnail.visible = false;
    }
  }

  function resizeToLarge(){
    kwinClientThumbnail.width = clientRealWidth;
    kwinClientThumbnail.height = clientRealHeight;
    kwinClientThumbnail.x = actualThumbnail.mapFromGlobal(clientRealX, clientRealY).x;
    kwinClientThumbnail.y = actualThumbnail.mapFromGlobal(clientRealX, clientRealY).y;
  }

    function callUpdateGrid() {
      // It seems that when we move a large to a small and vice versa, we don't
      // always properly trigger updates.
      // Actually, it seems we don't update our new parent properly.  WHAT.
      if (kwinClientThumbnail.clientObject.activities == workspace.currentActivity || kwinClientThumbnail.clientObject.activities == '') {
        if (kwinClientThumbnail.clientObject.desktop > -1) {
          if (kwinClientThumbnail.isLarge) {
            kwinClientThumbnail.parent = currentDesktopGrid.itemAt(kwinClientThumbnail.clientObject.desktop-1).children[0].children[0];
            if (workspace.currentDesktop == kwinClientThumbnail.clientObject.desktop) {
              kwinClientThumbnail.toggleVisible('visible');
            } else {
              //kwinClientThumbnail.toggleVisible('invisible');
            }
          } else {
            kwinClientThumbnail.parent = littleDesktopRepeater.itemAt(kwinClientThumbnail.clientObject.desktop-1).children[2].children[0];
            kwinClientThumbnail.toggleVisible('visible');
          }
        }
      } else {
        kwinClientThumbnail.parent = currentDesktopGridThumbnailContainer;
        kwinClientThumbnail.toggleVisible('invisible');
      }
      searchFieldAndResults.children[1].forceActiveFocus();
    }


}
