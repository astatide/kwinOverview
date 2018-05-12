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
    NumberAnimation { target: kwinClientThumbnail; property: "x";
      from: kwinClientThumbnail.mapFromItem(parent, parent.mapFromGlobal(clientRealX, clientRealY).x, parent.mapFromGlobal(clientRealX, clientRealY).y).x;
      to: kwinClientThumbnail.originalX;
      easing.amplitude: 2;
      easing.type: Easing.InOutQuad;
      duration: 1000}
    NumberAnimation { target: kwinClientThumbnail; property: "y";
      from: kwinClientThumbnail.mapFromItem(parent, parent.mapFromGlobal(clientRealX, clientRealY).x, parent.mapFromGlobal(clientRealX, clientRealY).y).y;
      to: kwinClientThumbnail.originalY;
      easing.amplitude: 2;
      easing.type: Easing.InOutQuad;
      duration: 1000}
  }
  ParallelAnimation {
    id: moveFromThumbnail
    NumberAnimation { target: kwinClientThumbnail; property: "height"; to: clientRealHeight; from: originalHeight}
    NumberAnimation { target: kwinClientThumbnail; property: "width"; to: clientRealWidth; from: originalWidth}
    //NumberAnimation { target: kwinClientThumbnail; property: "x"; to: clientRealX; from: kwinClientThumbnail.originalX}
    //NumberAnimation { target: kwinClientThumbnail; property: "y"; to: clientRealY; from: kwinClientThumbnail.originalY}
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
      workspace.activeClient = clientObject;
      dashboard.toggleBoth();
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
      console.log('New Desktop!');
      console.log(newDesktop);
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
    //setVisible();
    // WHY DOES THIS FIX IT?
    //shrinkToNothing.running = false;
    //growFromNothing.running = false;
    moveToThumbnail.running = false;
    moveFromThumbnail.running = false;
    growthAnim.running = false;
    shrinkAnim.running = false;
    // We really should be where our parents tell us to be
    //console.log('What is our grid position?');
    //console.log(kwinClientThumbnail.x, kwinClientThumbnail.y);
    //kwinClientThumbnail.originalX = kwinClientThumbnail.x;
    //kwinClientThumbnail.originalY = kwinClientThumbnail.y;
    //returnAnim.running = true;
    //x = kwinClientThumbnail.mapFromGlobal(clientRealX, clientRealY).x
    //y = kwinClientThumbnail.mapFromGlobal(clientRealX, clientRealY).y
    // Tell our managing function to send out a more global signal.
    //workspace.clientList()[clientId].desktopChanged.connect(function() {
      // Update our main grid.  Bit of a hack for now.
      // (this shouldn't really call our main stuff.)
    //  parent.parent.updateGrid();
    //  parent.updateGrid();
    //});

    //workspace.clientList()[model.index].desktopChanged.connect(function() {
      // If one of our things changes, just manually trigger a grid update.
      // For now, anyway.
    //  parent.updateGrid();
    //});
    //mainBackground.stateChanged.connect(runAnimations);
    //workspace.currentDesktopChanged.connect(updateGrid);
    //workspace.currentDesktopChanged.connect(updateGrid);
    //workspace.numberDesktopsChanged
    //workspace.clientAdded.connect(updateGrid);
    //workspace.clientRemoved.connect(updateGrid);
    //console.log('What are our coordinates?');
    //console.log(kwinClientThumbnail.mapFromGlobal(clientRealX, clientRealY));
    //console.log(kwinClientThumbnail.mapFromItem(parent, parent.mapFromGlobal(clientRealX, clientRealY).x, parent.mapFromGlobal(clientRealX, clientRealY).y));
  }

    function updateGrid(i, client) {
      // Probably won't work.
      kwinDesktopThumbnailContainer.desktop = workspace.currentDesktop-1;
      // But we actually need to rebuild the whole grid.  Huh!
      clientGridLayout.rows = clientGridLayout._returnMatrixSize();
      clientGridLayout.columns = clientGridLayout._returnMatrixSize();
      //width = kwinDesktopThumbnailContainer.width / clientGridLayout.columns;
      //height = kwinDesktopThumbnailContainer.height / clientGridLayout.columns;
      //originalWidth: kwinDesktopThumbnailContainer.width / clientGridLayout.columns
      //originalHeight: kwinDesktopThumbnailContainer.height / clientGridLayout.columns
      width = parent.width / clientGridLayout.columns;
      height = parent.height / clientGridLayout.columns;
      //clientGridLayout.height = dashboard.screenHeight - dash.height - 30
      //width: (dashboard.screenHeight - dash.height - 30)*dashboard.screenRatio
      //clientGridLayout.width = dashboard.screenWidth
      //setVisible();
    }
    function _overlapsDesktop(x, y) {
      // Here, we're going to determine if we're in a new desktop.
      console.log('Yay!');
      console.log(workspace.currentDesktop);
      //console.log(x, y);
      // If we drag it out of the bar, send it to the current desktop.
      console.log(x, y);
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
