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
  property int originalWidth: kwinDesktopThumbnailContainer.width / clientGridLayout.columns
  property int originalHeight: kwinDesktopThumbnailContainer.height / clientGridLayout.columns
  // This seems to be necessary to set everything appropriately.  Not 100% sure why.
  property int scale: 1
  property var originalParent: parent
  // Setting the height/width seems to break EVERYTHING, as the thumbnails are busted.
  //width: kwinDesktopThumbnailContainer.width / clientGridLayout.columns
  //height: kwinDesktopThumbnailContainer.height / clientGridLayout.columns
  // Get our actual client information.  This way, we can move through desktops/activities.
  property var clientObject: ''
  property int clientId: 0
  property var currentDesktop: 0

  opacity: 0

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

  Rectangle {
    //id: thumbnailBackgroundRectangle
    id: actualThumbnail
    // Don't fill the anchors; otherwise, it doesn't work.
    //anchors.fill: parent
    color: 'black'
    opacity: 1
    visible: true
    //scale:
    clip: true
    x: 0
    y: 0
    height: kwinClientThumbnail.height
    width: kwinClientThumbnail.width
    // Are THESE breaking it?  What the shit.
    // These DO seem to break it!  What the fuck.
    // Something about the way they're painted, maybe?  Not so good.
    KWinLib.ThumbnailItem {
      // Basically, this 'fills up' to the parent object, so we encapsulate it
      // so that we can shrink the thumbnail without messing with the grid itself.
      anchors.fill: actualThumbnail
      wId: workspace.clientList()[clientId].windowId
      //height: kwinClientThumbnail.height
      //width: kwinClientThumbnail.width
      x: 0
      y: 0
      z: 0
      visible: true
      clip: true
    }
  }
  // These don't really work yet, but hey.
  ParallelAnimation {
    id: moveToThumbnail
    NumberAnimation {
      //target: kwinClientThumbnail;
      target: actualThumbnail;
      property: "width";
      from: clientRealWidth//*(dashboard.screenWidth/currentDesktopGrid.width);
      to: kwinClientThumbnail.width;
      easing.amplitude: 2;
      easing.type: Easing.InOutQuad;
      //duration: 1000
    }
    NumberAnimation {
      //target: kwinClientThumbnail;
      target: actualThumbnail;
      property: "height";
      from: clientRealHeight*(dashboard.screenHeight/currentDesktopGrid.itemAt(workspace.currentDesktop-1).children[0].height);
      to: kwinClientThumbnail.height;
      easing.amplitude: 2;
      easing.type: Easing.InOutQuad;
      //duration: 1000
    }
    NumberAnimation {
      //target: kwinClientThumbnail;
      target: actualThumbnail;
      property: "x";
      from: kwinClientThumbnail.mapFromGlobal(clientRealX, clientRealY).x-actualThumbnail.mapFromItem(kwinClientThumbnail.parent, x, y).x;
      to: kwinClientThumbnail.originalX;
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
      from: kwinClientThumbnail.mapFromGlobal(clientRealX, clientRealY).y-actualThumbnail.mapFromItem(kwinClientThumbnail.parent, x, y).y;
      to: kwinClientThumbnail.originalY;
      //to: 0
      easing.amplitude: 2;
      easing.type: Easing.InOutQuad;
      //duration: 1000
    }
  }
  ParallelAnimation {
    id: moveFromThumbnail
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

    PropertyAnimation { target: actualThumbnail; property: "x"; to: shrinkAnim.animX-(50*dashboard.screenRatio); duration: 100}
    PropertyAnimation { target: actualThumbnail; property: "y"; to: shrinkAnim.animY-50; duration: 100}

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
        if (kwinClientThumbnail.mapToGlobal(mouse.x, mouse.y).y < dash.height + 30) {
              if (actualThumbnail.height != 100) {
              shrinkAnim.restart()
              ranAnimation = true;
          }
        } else if (kwinClientThumbnail.mapToGlobal(mouse.x, mouse.y).y > dash.height + 30) {
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
      // So doesn't work.
      kwinClientThumbnail.z = 1000;
      kwinClientThumbnail.state = 'isHeld';
    }
    onReleased: {
      kwinClientThumbnail.state = 'notHeld';
      var newDesktop = _overlapsDesktop(kwinClientThumbnail.mapToGlobal(mouse.x, mouse.y).x, kwinClientThumbnail.mapToGlobal(mouse.x, mouse.y).y);
      if (kwinClientThumbnail.isSmall) {
        growthAnim.running = true;
        kwinClientThumbnail.isSmall = false;
      }
      if (clientObject.desktop == newDesktop ) {
        //console.log(newDesktop);
        returnAnim.running = true;
        //growthAnim.running = true;
      } else if (newDesktop == 0) {
        returnAnim.running = true;
        //growthAnim.running = true;
      } else {
        clientObject.desktop = newDesktop;
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
    callUpdateGrid();
    clientObject.desktopChanged.connect(function() {
      // Update our main grid.  Bit of a hack for now.
      // (this shouldn't really call our main stuff.)
      // We just want to reparent ourselves.
      callUpdateGrid();
    });
    //resizeToLarge();
    //resizeToSmall();
  }

  function startMoveToThumbnail() {
    moveToThumbnail.restart();
  }
  function startMoveFromThumbnail() {
    moveFromThumbnail.restart();
  }

  function resizeToSmall(){
    kwinClientThumbnail.width = kwinClientThumbnail.originalWidth;
    kwinClientThumbnail.height = kwinClientThumbnail.originalHeight;
    kwinClientThumbnail.x = kwinClientThumbnail.originalX;
    kwinClientThumbnail.y = kwinClientThumbnail.originalY;
  }

  function resizeToLarge(){
    kwinClientThumbnail.width = clientRealWidth;
    kwinClientThumbnail.height = clientRealHeight;
    kwinClientThumbnail.x = actualThumbnail.mapFromGlobal(clientRealX, clientRealY).x;
    kwinClientThumbnail.y = actualThumbnail.mapFromGlobal(clientRealX, clientRealY).y;
  }

    function callUpdateGrid() {
      //parent.updateGrid();
      console.log('TESTG!!!');
      if (kwinClientThumbnail.isLarge) {
        //reparent ourselves to the new desktop item
        // it's always going to be the desktop.
        kwinClientThumbnail.parent = bigDesktopRepeater.itemAt(kwinClientThumbnail.clientObject.desktop);
      } else {
        // Command is broken.  Oh well.
        //console.log(Object.getOwnPropertyNames(desktopThumbnailGrid));
        //kwinClientThumbnail.parent = desktopThumbnailGrid.children[0];
        //kwinClientThumbnail.parent = desktopThumbnailGrid.children[0].children[1];
        //console.log(Object.getOwnPropertyNames(kwinClientThumbnail.parent = desktopThumbnailGrid.children[0].children[1]));
        //console.log(kwinClientThumbnail.parent = desktopThumbnailGrid.children[0].children[1]);
        //kwinClientThumbnail.parent = desktopThumbnailGrid.children[0].children[0].children[1].children[2].itemAt(kwinClientThumbnail.clientObject.desktop-1);
        //kwinClientThumbnail.parent = littleDesktopRepeater.itemAt(kwinClientThumbnail.clientObject.desktop).children[0].children[2];
        kwinClientThumbnail.parent = littleDesktopRepeater.itemAt(kwinClientThumbnail.clientObject.desktop+1).children[2];
        console.log(kwinClientThumbnail.parent)
        //kwinClientThumbnail.parent = desktopThumbnailGrid.children[0].children[0].children[1].itemAt(kwinClientThumbnail.clientObject.desktop-1);
        //kwinClientThumbnail.parent = desktopThumbnailGrid.children[0].children[1].itemAt(kwinClientThumbnail.clientObject.desktop-1).children[2];
      }
      kwinClientThumbnail.visible = true;
    }

    function _overlapsDesktop(x, y) {
      // Here, we're going to determine if we're in a new desktop.
      //console.log(x, y);
      // If we drag it out of the bar, send it to the current desktop.
      if (y > dash.height) {
        return workspace.currentDesktop;
      }
      for (var d = 0; d <= workspace.desktops; d++) {
        // We need to check if we're within the new bounds.  That's height and width!
        // or just width, actually.
        // x and y are now global coordinates.
        if (x < d*(dash.height*dashboard.screenRatio)) {
        // We have workspace.desktops, and our screen width is activeScreen.width
        //console.log(x, (d)*kwinDesktopThumbnailContainer.width + desktopThumbnailGridBackgrounds.width/(workspace.desktops) + dash.height*main.screenRatio, d);
        //if (x < (d)*kwinDesktopThumbnailContainer.width + desktopThumbnailGridBackgrounds.width/(workspace.desktops) + dash.height*dashboard.screenRatio) {
          return d
        }
        //if (x > (d-1*width)+activeScreen.width/(2*workspace.desktops)) {
        //  return d;
        }
        return 0;
      }

}
