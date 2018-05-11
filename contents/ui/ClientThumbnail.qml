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
  //property int scale: 1
  property var originalParent: parent
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

  //property bool isHeld: false
  property bool isSmall: false

  // For the mouse.
  property QtObject container

  states: [
    State {
      name: 'isHeld'
      PropertyChanges {
        target: actualThumbnail
        //parent: mainBackground
        z: 10000
      }
    },
    State {
      name: 'notHeld'
      PropertyChanges {
        target: actualThumbnail
        z: 0
        //parent: clientGridLayout
      }
    }
  ]

  // Connect to the client signal.
  //signal desktopChanged: { return workspace.clientList()[model.index].desktopChanged }

  // I want this to show up if compositing is disabled.
  Rectangle {
    //id: thumbnailBackgroundRectangle
    id: actualThumbnail
    //anchors.fill: parent
    //parent: parent.parent
    //width: kwinClientThumbnail.width
    //height: kwinClientThumbnail.height
    //width: kwinClientThumbnail.width
    //height: kwinClientThumbnail.height
    //width: 100
    //height: 100
    color: 'black'
    opacity: 0.25
    visible: true
    //scale:
    //clip: true
    height: kwinClientThumbnail.height
    width: kwinClientThumbnail.width
    // Are THESE breaking it?  What the shit.
    // These DO seem to break it!  What the fuck.
    // Something about the way they're painted, maybe?  Not so good.
    KWinLib.ThumbnailItem {
      //id: actualThumbnail
      //anchors.verticalCenter: parent.verticalCenter
      anchors.fill: actualThumbnail
      wId: workspace.clientList()[clientId].windowId
      //width: kwinClientThumbnail.width
      //height: kwinClientThumbnail.height
      //scale: 2
      //x: kwinClientThumbnail.x
      x: 0
      y: 0
      z: 0
      //y: kwinClientThumbnail.y
      visible: true
      clip: true
    }
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
  /*onHeightChanged: {
    kwinClientThumbnail.y = y+height/2;
  }
  onWidthChanged: {
    kwinClientThumbnail.x = x+width/2;
  }*/

  ParallelAnimation {
    id: shrinkAnim
    alwaysRunToEnd: false
    running: false
    property int animX: 0
    property int animY: 0
    /*PropertyAnimation {
      target: kwinClientThumbnail
      property: "height"
      to: 100
      duration: 100
    }
    PropertyAnimation {
      target: kwinClientThumbnail
      property: "width"
      to: 100*dashboard.screenRatio
      duration: 100
  }

    PropertyAnimation { target: kwinClientThumbnail; property: "x"; to: shrinkAnim.animX-(50*dashboard.screenRatio)+width/2; duration: 100}
    PropertyAnimation { target: kwinClientThumbnail; property: "y"; to: shrinkAnim.animY-50+height/2; duration: 100}*/

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
    /*NumberAnimation { target: kwinClientThumbnail; property: "height"; to: originalHeight; duration: 100}
    NumberAnimation { target: kwinClientThumbnail; property: "width"; to: originalWidth; duration: 100}

    PropertyAnimation { target: kwinClientThumbnail; property: "x"; to: growthAnim.animX+width/2-originalWidth/2; duration: 100}
    PropertyAnimation { target: kwinClientThumbnail; property: "y"; to: growthAnim.animY+height/2-originalHeight/2; duration: 100}*/
    NumberAnimation { target: actualThumbnail; property: "height"; to: originalHeight; duration: 100}
    NumberAnimation { target: actualThumbnail; property: "width"; to: originalWidth; duration: 100}

    PropertyAnimation { target: actualThumbnail; property: "x"; to: 0; duration: 100}
    PropertyAnimation { target: actualThumbnail; property: "y"; to: 0; duration: 100}

    //actualThumbnail.width = 100;
    //actualThumbnail.height = 100;
    //kwinClientThumbnail.width = 100;
    //kwinClientThumbnail.height = 100;
    //actualThumbnail.x = mouse.x-50
    //actualThumbnail.y = mouse.y-50
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
      //var mouseX = mainBackground.mapFromGlobal(kwinClientThumbnail.mapToGlobal(mouse.x, mouse.y).x, kwinClientThumbnail.mapToGlobal(mouse.x, mouse.y).y).x - width/2 //originalWidth/2 //- width/2;
      //var mouseY = mainBackground.mapFromGlobal(kwinClientThumbnail.mapToGlobal(mouse.x, mouse.y).x, kwinClientThumbnail.mapToGlobal(mouse.x, mouse.y).y).y - height/2 //originalHeight/2 //- height/2;
      //var mouseX = mainBackground.mapFromGlobal(kwinClientThumbnail.mapToGlobal(mouse.x, mouse.y).x, kwinClientThumbnail.mapToGlobal(mouse.x, mouse.y).y).x //originalWidth/2 //- width/2;
      //var mouseY = mainBackground.mapFromGlobal(kwinClientThumbnail.mapToGlobal(mouse.x, mouse.y).x, kwinClientThumbnail.mapToGlobal(mouse.x, mouse.y).y).y //originalHeight/2 //- height/2;
      shrinkAnim.animX = mouseX;
      shrinkAnim.animY = mouseY;
      growthAnim.animX = mouseX;
      growthAnim.animY = mouseY;
      //mouseArea.enabled = false;
      //if (kwinClientThumbnail.state == 'isHeld') {
      if (kwinClientThumbnail.state == 'isHeld') {
        if (kwinClientThumbnail.mapToGlobal(mouse.x, mouse.y).y < dash.height + 30) {
          // If we're not small, we want to shrink.
          //if (!kwinClientThumbnail.isSmall) {
            //shrinkAnim.restart()
            //mouseArea.enabled = false;
            // Check to make sure the animation isn't already running.
            //kwinClientThumbnail.isSmall = true;
            //if (!shrinkAnim.busy) {
              //shrinkAnim.stop();
              if (actualThumbnail.height != 100) {
              //shrinkAnim.animX = mouseX;
              //shrinkAnim.animY = mouseY;
              //shrinkAnim.running = true;
              shrinkAnim.restart()
              //scaleAnim.running = true;
              //ranAnimation = true;
              //}
              ranAnimation = true;
              //shrinkAnim.restart();
          }
        } else if (kwinClientThumbnail.mapToGlobal(mouse.x, mouse.y).y > dash.height + 30) {
          //if (kwinClientThumbnail.isSmall) {
            //if (!growthAnim.busy) {
              if (actualThumbnail.height != originalHeight) {
              // Avoids jerky behavior.
              //mouseArea.enabled = false;
              kwinClientThumbnail.isSmall = false;
              ranAnimation = true;
              growthAnim.restart();
            }
          }
      // If we didn't animate, then move the window.  With an animation!
      if (!ranAnimation) {
      //if (true) {
          //moveAnim.x = (kwinClientThumbnail.mapToGlobal(mouse.x, mouse.y).x - kwinClientThumbnail.mapToGlobal(originalX, originalY).x);
          //moveAnim.y = (kwinClientThumbnail.mapToGlobal(mouse.x, mouse.y).y - kwinClientThumbnail.mapToGlobal(originalX, originalY).y);
          // Is this happening in two steps or something?  What the fuck.
          //kwinClientThumbnail.x = (kwinClientThumbnail.mapToGlobal(mouseX, mouseY).x - kwinClientThumbnail.mapToGlobal(originalX, originalY).x);
          //kwinClientThumbnail.y = (kwinClientThumbnail.mapToGlobal(mouseX, mouseY).y - kwinClientThumbnail.mapToGlobal(originalX, originalY).y);
          var oX = kwinClientThumbnail.originalX;
          var oY = kwinClientThumbnail.originalY;

          moveAnim.animX = mouseX;
          moveAnim.animY = mouseY;
          //kwinClientThumbnail.x = mouseX;
          //kwinClientThumbnail.y = mouseY;
          //actualThumbnail.x = mouseX;
          //actualThumbnail.y = mouseY;
          //console.log(kwinClientThumbnail.parent);
          //moveAnim.restart();
          // We are NOT going to want to run this multiple times.
          //kwinClientThumbnail.parent = currentDesktopGrid;
          console.log(moveAnim.animX, moveAnim.animY);
          //console.log(kwinClientThumbnail.originalX == kwinClientThumbnail.x);
          //moveAnim.running = true;
      }
      }
    }

    onPressed: {
      // Bail on the grid, basically!?
      //x = kwinClientThumbnail.mapToItem()
      //ParentChange { target: kwinClientThumbnail; parent: dashboardBackground; x: 0; y: 0 }
      //moveAnim.animX = kwinClientThumbnail.parent.mapToGlobal(mouseX, mouseY).x; //- parent.mapToGlobal(oX, oY).x;
      //moveAnim.animY = kwinClientThumbnail.parent.mapToGlobal(mouseX, mouseY).y;
      // mouse.x and mouse.y are actually relative to our PARENT, already!?  So the grid, basically.
      // But our x and y are not relative to our parent.  Ugh ugh ugh.
      // For instance, if I click in the upper left corner, where the x and y coordinates are 0, 0, our
      // actual position is n pixels down from the dock, and m pixels from the left of the screen.
      // So we need to translate our coordinate transformations such that our origin is at our original position on the parent.
      // But how?
      //var mouseX = kwinClientThumbnail.mapFromGlobal(kwinClientThumbnail.parent.mapToGlobal(mouse.x, mouse.y).x, kwinClientThumbnail.parent.mapToGlobal(mouse.x, mouse.y).y).x;
      //var mouseY = kwinClientThumbnail.mapFromGlobal(kwinClientThumbnail.parent.mapToGlobal(mouse.x, mouse.y).x, kwinClientThumbnail.parent.mapToGlobal(mouse.x, mouse.y).y).y;
      //console.log(kwinClientThumbnail.originalX == kwinClientThumbnail.x);
      //var mouseX = kwinClientThumbnail.parent.mapFromItem(kwinClientThumbnail, mouse.x, mouse.y).x;
      //var mouseY = kwinClientThumbnail.parent.mapFromItem(kwinClientThumbnail, mouse.x, mouse.y).y;
      //var mouseY = mouse.y;
      //moveAnim.animX = mouseX; //- parent.mapToGlobal(oX, oY).x;
      //moveAnim.animY = mouseY;
      //moveAnim.animX = kwinClientThumbnail.mouseX; //- parent.mapToGlobal(oX, oY).x;
      //moveAnim.animY = mouseY;
      //moveAnim.running = true;
      //var mouseX = mainBackground.mapFromGlobal(kwinClientThumbnail.mapToGlobal(mouse.x, mouse.y).x, kwinClientThumbnail.mapToGlobal(mouse.x, mouse.y).y).x - width/2 //originalWidth/2 //- width/2;
      //var mouseY = mainBackground.mapFromGlobal(kwinClientThumbnail.mapToGlobal(mouse.x, mouse.y).x, kwinClientThumbnail.mapToGlobal(mouse.x, mouse.y).y).y - height/2 //originalHeight/2 //- height/2;
      //initMoveAnim.animX = mouseX;
      //initMoveAnim.animY = mouseY;
      //initMoveAnim.restart();
      //actualThumbnail.scale = 2;
      //actualThumbnail.width = 100;
      //actualThumbnail.height = 100;
      //kwinClientThumbnail.width = 100;
      //kwinClientThumbnail.height = 100;
      //actualThumbnail.x = mouse.x-50
      //actualThumbnail.y = mouse.y-50
      //actualThumbnail.visible = false;
      //shrinkAnim.start();
      console.log("yay");
      kwinClientThumbnail.originalX = kwinClientThumbnail.x;
      kwinClientThumbnail.originalY = kwinClientThumbnail.y;
      console.log('What is our grid position?');
      // ... or is this relative to the main background?
      console.log(mouse.x, mouse.y);
      console.log(kwinClientThumbnail.mapToItem(currentDesktopGrid, mouse.x, mouse.y));
      console.log(kwinClientThumbnail.x, kwinClientThumbnail.y);
      // Draw above everything else!
      kwinClientThumbnail.originalZ = kwinClientThumbnail.z;
      // So doesn't work.
      kwinClientThumbnail.z = 1000;
      kwinClientThumbnail.state = 'isHeld';
      //onPositionChanged: {
      //}
      //growthAnim.running = true;
    }
    onReleased: {
      //kwinClientThumbnail.parent = clientGridLayout;
      kwinClientThumbnail.state = 'notHeld';
      console.log(kwinClientThumbnail.parent);
      //clientGridLayout.updateGrid();
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
