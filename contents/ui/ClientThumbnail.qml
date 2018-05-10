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
  //property int scale: (kwinDesktopThumbnailContainer.height / (kwinDesktopThumbnailContainer.width)) / (dashboard.screenHeight/dashboard.screenWidth)
  property int scale: 1
  // Setting the height/width seems to break EVERYTHING, as the thumbnails are busted.
  //width: kwinDesktopThumbnailContainer.width / clientGridLayout.columns
  //height: kwinDesktopThumbnailContainer.height / clientGridLayout.columns
  // Get our actual client information.  This way, we can move through desktops/activities.
  //property var clientObject: { workspace.clientList()[model.index] }
  // Set by the calling object.
  property var clientObject: ''
  property int clientId: 0
  //anchors.fill: parent

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

  property bool isHeld: false
  property bool isSmall: false

  // For the mouse.
  property QtObject container

  // Connect to the client signal.
  //signal desktopChanged: { return workspace.clientList()[model.index].desktopChanged }

  // Are THESE breaking it?  What the shit.
  // These DO seem to break it!  What the fuck.
  // Something about the way they're painted, maybe?  Not so good.
  KWinLib.ThumbnailItem {
    id: actualThumbnail
    //anchors.verticalCenter: parent.verticalCenter
    anchors.fill: parent
    wId: workspace.clientList()[clientId].windowId
    //width: kwinClientThumbnail.width
    //height: kwinClientThumbnail.height
    //x: kwinClientThumbnail.x
    x: 0
    y: 0
    z: 0
    //y: kwinClientThumbnail.y
    visible: true
    clip: true
  }
  // I want this to show up if compositing is disabled.
  Rectangle {
    id: thumbnailBackgroundRectangle
    anchors.fill: parent
    //width: kwinClientThumbnail.width
    //height: kwinClientThumbnail.height
    color: 'black'
    opacity: 1
    visible: true
    //clip: true
    x: 0
    y: 0
  }
  // These don't really work yet, but hey.
  ParallelAnimation {
    id: moveToThumbnail
    //NumberAnimation { target: kwinClientThumbnail; property: "height"; from: clientRealHeight/scale; to: originalHeight; easing.amplitude: 2; easing.type: Easing.InOutQuad; duration: 1000}
    //NumberAnimation { target: kwinClientThumbnail; property: "width"; from: clientRealWidth/scale; to: originalWidth; easing.amplitude: 2; easing.type: Easing.InOutQuad; duration: 1000}
    //NumberAnimation { target: kwinClientThumbnail; property: "height"; from: clientRealHeight; to: clientRealHeight; easing.amplitude: 2; easing.type: Easing.InOutQuad; duration: 1000}
    //NumberAnimation { target: kwinClientThumbnail; property: "width"; from: clientRealWidth; to: clientRealWidth; easing.amplitude: 2; easing.type: Easing.InOutQuad; duration: 1000}
    //NumberAnimation { target: kwinClientThumbnail; property: "x"; from: kwinClientThumbnail.mapFromItem(currentDesktopGrid, currentDesktopGrid.mapFromGlobal(clientRealX, clientRealY)).x; to: kwinClientThumbnail.originalX; easing.amplitude: 2; easing.type: Easing.InOutQuad; duration: 1000}
    //NumberAnimation { target: kwinClientThumbnail; property: "y"; from: kwinClientThumbnail.mapFromItem(currentDesktopGrid, currentDesktopGrid.mapFromGlobal(clientRealX, clientRealY)).y; to: kwinClientThumbnail.originalY; easing.amplitude: 2; easing.type: Easing.InOutQuad; duration: 1000}
    // So, we have the original X and Y position from the actual client.  These coordinates should be good relative to the screen.  We want to map from those to our grid position.
    //NumberAnimation { target: kwinClientThumbnail; property: "x"; from: kwinClientThumbnail.mapFromItem(dashboard, clientRealX, clientRealY).x; to: kwinClientThumbnail.originalX; easing.amplitude: 2; easing.type: Easing.InOutQuad; duration: 1000}
    //NumberAnimation { target: kwinClientThumbnail; property: "y"; from: kwinClientThumbnail.mapFromItem(dashboard, clientRealX, clientRealY).y; to: kwinClientThumbnail.originalY; easing.amplitude: 2; easing.type: Easing.InOutQuad; duration: 1000}
    //NumberAnimation { target: kwinClientThumbnail; property: "x"; from: actualThumbnail.mapFromGlobal(clientRealX, clientRealY).x; to: kwinClientThumbnail.originalX; easing.amplitude: 2; easing.type: Easing.InOutQuad; duration: 1000}
    //NumberAnimation { target: kwinClientThumbnail; property: "y"; from: actualThumbnail.mapFromGlobal(clientRealX, clientRealY).y; to: kwinClientThumbnail.originalY; easing.amplitude: 2; easing.type: Easing.InOutQuad; duration: 1000}
    //NumberAnimation { target: kwinClientThumbnail; property: "x"; from: clientRealX; to: kwinClientThumbnail.originalX; easing.amplitude: 2; easing.type: Easing.InOutQuad; duration: 1000}
    //NumberAnimation { target: kwinClientThumbnail; property: "y"; from: clientRealY; to: kwinClientThumbnail.originalY; easing.amplitude: 2; easing.type: Easing.InOutQuad; duration: 1000}
    //NumberAnimation { target: kwinClientThumbnail; property: "x"; from: kwinDesktopThumbnailContainer.mapFromGlobal(clientRealX, clientRealY).x; to: kwinClientThumbnail.originalX; easing.amplitude: 2; easing.type: Easing.InOutQuad; duration: 1000}
    //NumberAnimation { target: kwinClientThumbnail; property: "y"; from: kwinDesktopThumbnailContainer.mapFromGlobal(clientRealX, clientRealY).y; to: kwinClientThumbnail.originalY; easing.amplitude: 2; easing.type: Easing.InOutQuad; duration: 1000}
    //NumberAnimation { target: kwinClientThumbnail; property: "x"; from: kwinClientThumbnail.mapFromGlobal(clientRealX, clientRealY).x; to: kwinClientThumbnail.originalX; easing.amplitude: 2; easing.type: Easing.InOutQuad; duration: 1000}
    //NumberAnimation { target: kwinClientThumbnail; property: "y"; from: kwinClientThumbnail.mapFromGlobal(clientRealX, clientRealY).y; to: kwinClientThumbnail.originalY; easing.amplitude: 2; easing.type: Easing.InOutQuad; duration: 1000}
    //NumberAnimation { target: kwinClientThumbnail; property: "x"; from: clientRealX; to: kwinClientThumbnail.originalX; easing.amplitude: 2; easing.type: Easing.InOutQuad; duration: 1000}
    //NumberAnimation { target: kwinClientThumbnail; property: "y"; from: clientRealY; to: kwinClientThumbnail.originalY; easing.amplitude: 2; easing.type: Easing.InOutQuad; duration: 1000}
    //NumberAnimation { target: kwinClientThumbnail; property: "x"; from: dashboard.mapFromGlobal(clientRealX, clientRealY).x; to: kwinClientThumbnail.originalX; easing.amplitude: 2; easing.type: Easing.InOutQuad; duration: 1000}
    //NumberAnimation { target: kwinClientThumbnail; property: "y"; from: dashboard.mapFromGlobal(clientRealX, clientRealY).y; to: kwinClientThumbnail.originalY; easing.amplitude: 2; easing.type: Easing.InOutQuad; duration: 1000}
    //NumberAnimation { target: kwinClientThumbnail; property: "x"; from: kwinClientThumbnail.mapFromGlobal(clientRealX, clientRealY).x; to: kwinClientThumbnail.originalX; easing.amplitude: 2; easing.type: Easing.InOutQuad; duration: 1000}
    //NumberAnimation { target: kwinClientThumbnail; property: "y"; from: kwinClientThumbnail.mapFromGlobal(clientRealX, clientRealY).y; to: kwinClientThumbnail.originalX; easing.amplitude: 2; easing.type: Easing.InOutQuad; duration: 1000}
    //NumberAnimation { target: kwinClientThumbnail; property: "x"; from: kwinClientThumbnail.mapFromGlobal(clientRealX, clientRealY).x; to: kwinClientThumbnail.mapToItem(parent, 0,0).x; easing.amplitude: 2; easing.type: Easing.InOutQuad; duration: 1000}
    //NumberAnimation { target: kwinClientThumbnail; property: "y"; from: kwinClientThumbnail.mapFromGlobal(clientRealX, clientRealY).y; to: kwinClientThumbnail.mapToItem(parent, 0,0).y; easing.amplitude: 2; easing.type: Easing.InOutQuad; duration: 1000}
    // This works so long as we only set the originalX and Y once.
    //NumberAnimation { target: kwinClientThumbnail; property: "x"; from: 0; to: kwinClientThumbnail.originalX; easing.amplitude: 2; easing.type: Easing.InOutQuad; duration: 1000}
    //NumberAnimation { target: kwinClientThumbnail; property: "y"; from: 0; to: kwinClientThumbnail.originalY; easing.amplitude: 2; easing.type: Easing.InOutQuad; duration: 1000}
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
    //NumberAnimation { target: actualThumbnail; property: "width"; from: width; to: width*2}
    //NumberAnimation { target: actualThumbnail; property: "height"; from: height; to: height*2}
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
    //NumberAnimation { target: actualThumbnail; property: "width"; from: width; to: width/2}
    //NumberAnimation { target: actualThumbnail; property: "height"; from: height; to: height/2}
  }
  ParallelAnimation {
    id: shrinkAnim
    alwaysRunToEnd: true
    running: false
    NumberAnimation { target: kwinClientThumbnail; property: "height"; from: originalHeight; to: 100}
    NumberAnimation { target: kwinClientThumbnail; property: "width"; from: originalWidth; to: 100}
    //NumberAnimation { target: kwinClientThumbnail; property: "y"; to: y+originalHeight/2}
    //NumberAnimation { target: kwinClientThumbnail; property: "x"; to: x+originalWidth/2}
    onStopped: {
      mouseArea.enabled = true;
    }
  }
  ParallelAnimation {
    id: growthAnim
    alwaysRunToEnd: true
    running: false
    NumberAnimation { target: kwinClientThumbnail; property: "height"; to: originalHeight}
    NumberAnimation { target: kwinClientThumbnail; property: "width"; to: originalWidth}
    //NumberAnimation { target: kwinClientThumbnail; property: "y"; to: y-originalHeight/2}
    //NumberAnimation { target: kwinClientThumbnail; property: "x"; to: x-originalWidth/2}
    onStopped: {
      mouseArea.enabled = true;
    }
  }

  MouseArea {
    id: mouseArea
    anchors.fill: parent
    //drag.axis: 'XAndYAxis'
    //drag.target: kwinClientThumbnail
    //hoverEnabled: true
    onClicked: {
      workspace.activeClient = clientObject;
      dashboard.toggleBoth();
    }

    onPositionChanged: {
      kwinClientThumbnail.x = kwinClientThumbnail.mapToGlobal(mouse.x, mouse.y).x - kwinClientThumbnail.originalX;
      kwinClientThumbnail.y = kwinClientThumbnail.mapToGlobal(mouse.x, mouse.y).y - kwinClientThumbnail.originalY;
      //kwinClientThumbnail.y = kwinClientThumbnail.mapFromGlobal(kwinClientThumbnail.mapToGlobal(mouse.x, mouse.y).x, kwinClientThumbnail.mapToGlobal(mouse.x, mouse.y).y).y;
      //kwinClientThumbnail.y = kwinClientThumbnail.mapToGlobal(mouse.x, mouse.y).y;
      if (kwinClientThumbnail.isHeld == true) {
        if (kwinClientThumbnail.mapToGlobal(mouse.x, mouse.y).y < dash.height + 30) {
          // If we're not small, we want to shrink.
          if (!kwinClientThumbnail.isSmall) {
            //mouseArea.enabled = false;
            // Check to make sure the animation isn't already running.
            kwinClientThumbnail.isSmall = true;
            if (!shrinkAnim.busy) {
              mouseArea.enabled = false;
              shrinkAnim.running = true;
              }
          }
        } else if (kwinClientThumbnail.mapToGlobal(mouse.x, mouse.y).y > dash.height + 30) {
          if (kwinClientThumbnail.isSmall) {
            kwinClientThumbnail.isSmall = false;
            if (!growthAnim.busy) {
              // Avoids jerky behavior.
              //mouseArea.enabled = false;
              mouseArea.enabled = false;
              growthAnim.running = true;
            }
          }
        }
      }
    }

    onPressed: {
      kwinClientThumbnail.originalX = kwinClientThumbnail.x;
      kwinClientThumbnail.originalY = kwinClientThumbnail.y;
      console.log('What is our grid position?');
      console.log(kwinClientThumbnail.x, kwinClientThumbnail.y);
      // Draw above everything else!
      kwinClientThumbnail.originalZ = kwinClientThumbnail.z;
      kwinClientThumbnail.z = 1000;
      kwinClientThumbnail.isHeld = true;
      //onPositionChanged: {
      //}
      //growthAnim.running = true;
    }
    onReleased: {
      // We want to move it to the desktop.
      //console.log(Object.getOwnPropertyNames(mouse));
      // These are where the mouse CLICKED on the object.  Blah.
      var newDesktop = clientGridLayout._overlapsDesktop(kwinClientThumbnail.mapToGlobal(mouse.x, mouse.y).x, kwinClientThumbnail.mapToGlobal(mouse.x, mouse.y).y);
      //console.log(kwinClientThumbnail.mapToGlobal(mouse.x, mouse.y));
      console.log('New Desktop!');
      console.log(newDesktop);
      // Hey, it works.  Yay.
      //console.log(Object.getOwnPropertyNames(workspace));
      //console.log(Object.getOwnPropertyNames(clientObject));
      kwinClientThumbnail.isHeld = false;
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
            // Why does this hack work?
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
    workspace.clientList()[clientId].desktopChanged.connect(function() {
      // Update our main grid.  Bit of a hack for now.
      // (this shouldn't really call our main stuff.)
      parent.updateGrid();
    });
    //mainBackground.stateChanged.connect(runAnimations);
    //workspace.currentDesktopChanged.connect(updateGrid);
    //workspace.currentDesktopChanged.connect(updateGrid);
    //workspace.numberDesktopsChanged
    //workspace.clientAdded.connect(updateGrid);
    //workspace.clientRemoved.connect(updateGrid);
    console.log('What are our coordinates?');
    console.log(kwinClientThumbnail.mapFromGlobal(clientRealX, clientRealY));
    console.log(kwinClientThumbnail.mapFromItem(parent, parent.mapFromGlobal(clientRealX, clientRealY).x, parent.mapFromGlobal(clientRealX, clientRealY).y));
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
}
