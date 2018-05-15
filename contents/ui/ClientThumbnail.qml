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
  z: 0
  property int originalZ: 0

  //property bool isHeld: false
  property bool isSmall: false
  property bool isLarge: false

  // For the mouse.
  property QtObject container

  states: [
    State {
      name: 'isHeld'
      PropertyChanges {
        target: kwinClientThumbnail
        //parent: mainBackground
        z: 10000
      }
    },
    State {
      name: 'notHeld'
      PropertyChanges {
        target: kwinClientThumbnail
        z: 0
        //parent: clientGridLayout
      }
    }
  ]

  // Connect to the client signal.
  //signal desktopChanged: { return workspace.clientList()[model.index].desktopChanged }

  // I want this to show up if compositing is disabled.  But it doesn't, so heeeeey.

  Item {
    id: actualThumbnail
    //anchors.fill kwinClientThumbnail
    height: kwinClientThumbnail.height
    width: kwinClientThumbnail.width
    visible: false
    opacity: 1
    //x: 0
    //y: 0
    /*Image {
      anchors.fill: parent
      smooth: true
      visible: true
      fillMode: Image.PreserveAspectCrop
      source: dashboardBackground.background
      height: kwinClientThumbnail.height
      width: kwinClientThumbnail.width
      x: 0
      y: 0
    }*/
    Rectangle {
      //id: thumbnailBackgroundRectangle
      // This is a test rectangle.  Ultimately, I'd like to show this when compositing is off.
      anchors.fill: parent
      //anchors.fill kwinClientThumbnail
      color: 'black'
      opacity: 0.5
      visible: false
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
    }
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
  // These don't really work yet, but hey.
  ParallelAnimation {
    id: moveToThumbnail
    running: false
    NumberAnimation {
      //target: kwinClientThumbnail;
      target: actualThumbnail;
      property: "width";
      from: clientRealWidth//*dashboard.screenWidth//currentDesktopGrid.width);
      to: kwinClientThumbnail.originalWidth;
      easing.amplitude: 2;
      easing.type: Easing.InOutQuad;
      //duration: 1000
    }
    NumberAnimation {
      //target: kwinClientThumbnail;
      target: actualThumbnail;
      property: "height";
      //from: clientRealHeight//*(dashboard.screenHeight/currentDesktopGrid.itemAt(workspace.currentDesktop-1).children[0].height);
      from: clientRealHeight//*dashboard.screenHeight///currentDesktopGrid.itemAt(workspace.currentDesktop-1).children[0].height);
      to: kwinClientThumbnail.originalHeight;
      easing.amplitude: 2;
      easing.type: Easing.InOutQuad;
      //duration: 1000
    }
  }
  ParallelAnimation {
    id: moveFromThumbnail
    running: false
    NumberAnimation {
      //target: kwinClientThumbnail;
      target: actualThumbnail;
      property: "width";
      to: clientRealWidth;
      from: kwinClientThumbnail.width;
      easing.amplitude: 2;
      easing.type: Easing.InOutQuad;
      //duration: 1000
    }
    NumberAnimation {
      //target: kwinClientThumbnail;
      target: actualThumbnail;
      property: "height";
      to: clientRealHeight*(dashboard.screenHeight/currentDesktopGrid.itemAt(workspace.currentDesktop-1).children[0].height);
      from: kwinClientThumbnail.height;
      easing.amplitude: 2;
      easing.type: Easing.InOutQuad;
      //duration: 1000
    }
    NumberAnimation {
      //target: kwinClientThumbnail;
      target: actualThumbnail;
      property: "x";
      to: kwinClientThumbnail.mapFromGlobal(clientRealX, clientRealY).x-actualThumbnail.mapFromItem(kwinClientThumbnail.parent, x, y).x;
      from: kwinClientThumbnail.originalX;
      //to: 0
      easing.amplitude: 2;
      easing.type: Easing.InOutQuad;
      //duration: 1000
    }
    NumberAnimation {
      //target: kwinClientThumbnail;
      target: actualThumbnail;
      property: "y";
      //from: clientRealY;
      // We want what the global coordinates of the client would be mapped to our thumbnail.
      // But why does this work when we're maximized, and not otherwise?
      // Our coordinate scales should be the same, so.
      to: kwinClientThumbnail.mapFromGlobal(clientRealX, clientRealY).y-actualThumbnail.mapFromItem(kwinClientThumbnail.parent, x, y).y;
      from: kwinClientThumbnail.originalY;
      //to: 0
      easing.amplitude: 2;
      easing.type: Easing.InOutQuad;
      //duration: 1000
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
      property: "height"
      to: 100
      duration: 100
    }
    PropertyAnimation {
      target: actualThumbnail
      property: "width"
      to: 100*dashboard.screenRatio
      duration: 100
  }

    PropertyAnimation { target: actualThumbnail; property: "x"; to: shrinkAnim.animX-(dash.gridHeight/2*dashboard.screenRatio); duration: 100}
    PropertyAnimation { target: actualThumbnail; property: "y"; to: shrinkAnim.animY-dash.gridHeight/2; duration: 100}

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
    NumberAnimation { target: actualThumbnail; property: "height"; to: originalHeight; duration: 100}
    NumberAnimation { target: actualThumbnail; property: "width"; to: originalWidth; duration: 100}

    //PropertyAnimation { target: actualThumbnail; property: "x"; from: growthAnim.animX; to: 0; duration: 1000}
    //PropertyAnimation { target: actualThumbnail; property: "y"; from: growthAnim.animY; to: 0; duration: 1000}
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
    PropertyAnimation { target: kwinClientThumbnail; property: "y"; to: moveAnim.animY; duration: 32; easing.amplitude: 2; easing.type: Easing.InOutQuad;}
    PropertyAnimation { target: kwinClientThumbnail; property: "x"; to: moveAnim.animX; duration: 32; easing.amplitude: 2; easing.type: Easing.InOutQuad;}
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
    hoverEnabled: true
    onClicked: {
      // We only want to disable the dashboard when we double click on the item
      // or when we're currently on said desktop and are 'sure'.
      if (currentDesktop == workspace.currentDesktop) {
        dashboard.toggleBoth();
      }
      workspace.activeClient = clientObject;
    }

    onPositionChanged: {
      // Let's do this proper.
      //console.log('CHANGING POSITIONS');
      var ranAnimation = false;
      var mouseX = mouse.x;
      var mouseY = mouse.y;
      shrinkAnim.animX = mouseX;
      shrinkAnim.animY = mouseY;
      growthAnim.animX = mouseX;
      growthAnim.animY = mouseY;

      if (kwinClientThumbnail.state == 'isHeld') {
        if (kwinClientThumbnail.mapToGlobal(mouse.x, mouse.y).y < dash.gridHeight + 30) {
              if (actualThumbnail.height != dash.gridHeight) {
              shrinkAnim.restart()
              ranAnimation = true;
          }
        } else if (kwinClientThumbnail.mapToGlobal(mouse.x, mouse.y).y > dash.gridHeight + 30) {
              if (actualThumbnail.height != originalHeight) {
              kwinClientThumbnail.isSmall = false;
              ranAnimation = true;
              growthAnim.restart();
            }
          }
      }
    }

    onPressed: {
      // Sets things up for the return animation.
      kwinClientThumbnail.originalX = kwinClientThumbnail.x;
      kwinClientThumbnail.originalY = kwinClientThumbnail.y;
      kwinClientThumbnail.originalZ = kwinClientThumbnail.z;
      kwinClientThumbnail.clientObject.keepAbove = true;
      // So doesn't work.
      kwinClientThumbnail.z = 1000;
      kwinClientThumbnail.state = 'isHeld';
    }
    onReleased: {
      kwinClientThumbnail.state = 'notHeld';
      kwinClientThumbnail.clientObject.keepAbove = false;
      var newDesktop = _overlapsDesktop(kwinClientThumbnail.mapToGlobal(mouse.x, mouse.y).x, kwinClientThumbnail.mapToGlobal(mouse.x, mouse.y).y);
      //growthAnim.animX = kwinClientThumbnail.mapToGlobal(mouseX, mouseY).x;
      //growthAnim.animY = kwinClientThumbnail.mapToGlobal(mouseX, mouseY).y;
      if (kwinClientThumbnail.isSmall) {
        growthAnim.running = true;
        kwinClientThumbnail.isSmall = false;
      }
      if (kwinClientThumbnail.clientObject.desktop == newDesktop ) {
        //console.log(newDesktop);
        returnAnim.running = true;
        //growthAnim.running = true;
      } else if (newDesktop == 0) {
        returnAnim.running = true;
        //growthAnim.running = true;
      } else {
        kwinClientThumbnail.clientObject.desktop = newDesktop;
        // We need to make it invisible, as well.
        //kwinClientThumbnail.visible = false;
        returnAnim.running = true;
        kwinClientThumbnail.z = kwinClientThumbnail.originalZ;
        // We want the others to pop up, so.
      }
    }
  }

  function runAnimations() {
    if (visible) {
      if (mainBackground.state == 'visible') {
        if (kwinClientThumbnail.originalX == 0) {
          if (kwinClientThumbnail.originalY == 0) {
            // Why does this hack work?  Can I make it a copy?
            // WHERE is it fucking updating!?
            kwinClientThumbnail.originalX = kwinClientThumbnail.x;
            kwinClientThumbnail.originalY = kwinClientThumbnail.y;
          }
        }
        moveToThumbnail.running = true;
      } else {
        moveFromThumbnail.running = true;
      }
    }
  }

  Component.onCompleted: {
    // We just check to see whether we're on the current desktop.
    // If not, don't show it.
    moveToThumbnail.running = false;
    moveFromThumbnail.running = false;
    growthAnim.running = false;
    shrinkAnim.running = false;
    clientObject.desktopChanged.connect(callUpdateGrid);
    clientObject.activitiesChanged.connect(callUpdateGrid);
    workspace.currentActivityChanged.connect(callUpdateGrid);
    mainBackground.onStateChanged.connect(toggleVisible);
    workspace.clientRemoved.connect(disconnectAllSignals);
    callUpdateGrid();
  }

  function disconnectAllSignals(c) {
    console.log(c);
    if (c) {
      if (c.windowId == kwinClientThumbnail.clientId) {
        console.log('KILLING MYSELF');
        // Yes, we even have to disconnect this.
        workspace.clientRemoved.disconnect(disconnectAllSignals);
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
      //runMoveToThumbnailAnim();
      // only toggle the ones on the current activity.
      if (kwinClientThumbnail.clientObject.activities == workspace.currentActivity || kwinClientThumbnail.clientObject.activities == '') {
        actualThumbnail.visible = true;
        kwinThumbnailRenderWindow.visible = true;
        kwinThumbnailRenderWindow.enabled = true;
        kwinClientThumbnail.visible = true;
      }
    } else if (state == 'invisible') {
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
      //console.log('TESTG!!!');
      // It seems that when we move a large to a small and vice versa, we don't
      // always properly trigger updates.
      // Actually, it seems we don't update our new parent properly.  WHAT.
      if (kwinClientThumbnail.isLarge) {
        //reparent ourselves to the new desktop item
        // it's always going to be the desktop.
        //console.log('LARGE DESKTOP!');
        console.log('TESTING ACTIVITIES');
        if (kwinClientThumbnail.clientObject.activities == workspace.currentActivity || kwinClientThumbnail.clientObject.activities == '') {
          //if (kwinClientThumbnail.clientObject.desktop > -1 && !kwinClientThumbnail.clientObject.dock) {
          if (kwinClientThumbnail.clientObject.desktop > -1) {
            // Reparent, then resize all the appropriate grids.
            // But also check to make sure we're on the correct activity.
            kwinClientThumbnail.parent = currentDesktopGrid.itemAt(kwinClientThumbnail.clientObject.desktop-1).children[0].children[0];
            kwinClientThumbnail.currentDesktop = kwinClientThumbnail.clientObject.desktop;
            kwinClientThumbnail.visible = true;
            actualThumbnail.visible = true;
          }
        } else {
            // Go back to being in the original parent widget.
            kwinClientThumbnail.parent = currentDesktopGridThumbnailContainer;
            kwinClientThumbnail.visible = false;
            actualThumbnail.visible = false;
          }
      } else {
      //console.log('SMALL DESKTOP!');
        if (kwinClientThumbnail.clientObject.activities == workspace.currentActivity || kwinClientThumbnail.clientObject.activities == '') {
          //if (kwinClientThumbnail.clientObject.desktop > -1 && !kwinClientThumbnail.clientObject.dock) {
          if (kwinClientThumbnail.clientObject.desktop > -1) {
            // Reparent, then resize all the appropriate grids.
            kwinClientThumbnail.currentDesktop = kwinClientThumbnail.clientObject.desktop;
            kwinClientThumbnail.visible = true;
            actualThumbnail.visible = true;
            kwinClientThumbnail.parent = littleDesktopRepeater.itemAt(kwinClientThumbnail.clientObject.desktop-1).children[2].children[0];
          }
        } else {
          console.log('REPARENTING');
          console.log('MAKE ME INVISIBLE');
          kwinClientThumbnail.visible = false;
          actualThumbnail.visible = false;
          kwinClientThumbnail.parent = desktopThumbnailGrid;
        }
      }
    }

    function _overlapsDesktop(x, y) {
      // Here, we're going to determine if we're in a new desktop.
      //console.log(x, y);
      // If we drag it out of the bar, send it to the current desktop.
      if (y > dash.gridHeight) {
        return workspace.currentDesktop;
      }
      for (var d = 0; d <= workspace.desktops; d++) {
        // We need to check if we're within the new bounds.  That's height and width!
        // or just width, actually.
        // x and y are now global coordinates.
        if (x < d*(dash.gridHeight*dashboard.screenRatio)) {
        // We have workspace.desktops, and our screen width is activeScreen.width
        //console.log(x, (d)*kwinDesktopThumbnailContainer.width + desktopThumbnailGridBackgrounds.width/(workspace.desktops) + dash.gridHeight*main.screenRatio, d);
        //if (x < (d)*kwinDesktopThumbnailContainer.width + desktopThumbnailGridBackgrounds.width/(workspace.desktops) + dash.gridHeight*dashboard.screenRatio) {
          return d
        }
        //if (x > (d-1*width)+activeScreen.width/(2*workspace.desktops)) {
        //  return d;
        }
        return 0;
      }

      function runGrowthAnim() {
        // We set the global mouse position when we released the item.
        // This is called when we reparent.  Now, we want to change our global mouse
        // coordinates to the local coordinates.
        //growthAnim.animX = kwinClientThumbnail.mapFromGlobal(growthAnim.animX, growthAnim.animY).x;
        //growthAnim.animY = kwinClientThumbnail.mapFromGlobal(growthAnim.animX, growthAnim.animY).y;
        growthAnim.restart();
      }
      function runMoveToThumbnailAnim() {
        // We set the global mouse position when we released the item.
        // This is called when we reparent.  Now, we want to change our global mouse
        // coordinates to the local coordinates.
        //growthAnim.animX = kwinClientThumbnail.mapFromGlobal(growthAnim.animX, growthAnim.animY).x;
        //growthAnim.animY = kwinClientThumbnail.mapFromGlobal(growthAnim.animX, growthAnim.animY).y;
        if (isLarge) {
          //if (kwinClientThumbnail.parent.isMain) {
          if (kwinClientThumbnail.currentDesktop == workspace.currentDesktop) {
          //if (!currentDesktopGrid.itemAt(kwinClientThumbnail.clientObject.desktop-1).children[0].children[0].isMain) {
            // This is too slow.
            //moveToThumbnail.restart();
          }
        }
      }

}
