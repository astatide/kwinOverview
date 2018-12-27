import QtQuick 2.2
import org.kde.kwin 2.0 as KWinLib
import QtQuick.Window 2.2
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
  //flags: Qt.WA_TranslucentBackground | Qt.X11BypassWindowManagerHint
  // We need to dynamically set these.
  //property int originalWidth: kwinDesktopThumbnailContainer.width / clientGridLayout.columns
  //property int originalHeight: kwinDesktopThumbnailContainer.height / clientGridLayout.columns
  property int originalWidth: 0
  property int originalHeight: 0

  //height: originalHeight
  //width: originalWidth
  // This seems to be necessary to set everything appropriately.  Not 100% sure why.
  property int scale: 1
  property var cId: 0
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
  property var oldParent: 0
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
  property var noBorder: false
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
        //target: kwinClientThumbnail
        //parent: mainBackground
        // This allows the visual to drag!
        target: dashboardDesktopChanger
        height: dashboard.screenHeight //- 120*dashboard.scalingFactor
      }
    },
    State {
      name: 'notHeld'
      PropertyChanges {
        //target: kwinClientThumbnail
        target: dashboardDesktopChanger
        height: (100+20) * dashboard.scalingFactor
        //parent: clientGridLayout
      }
    }
  ]
  Behavior on height { NumberAnimation { duration: 250 } }
  Behavior on width { NumberAnimation { duration: 250 } }
  Behavior on x { NumberAnimation { duration: 250 } }
  Behavior on y { NumberAnimation { duration: 250 } }
  /*transitions: Transition {
    ParentAnimation {
      ParallelAnimation {
        NumberAnimation { properties: "x,y"; duration: 1000 }
        NumberAnimation { target: actualThumbnail; property: "x"; from: kwinClientThumbnail.clientRealX; to: x}
        NumberAnimation { target: actualThumbnail; property: "y"; from: kwinClientThumbnail.clientRealY; to: y}
        NumberAnimation { target: kwinClientThumbnail; property: "x"; from: kwinClientThumbnail.clientRealX; to: x}
        NumberAnimation { target: kwinClientThumbnail; property: "y"; from: kwinClientThumbnail.clientRealY; to: y}
        NumberAnimation { target: kwinClientThumbnail; property: "height"; from: kwinClientThumbnail.clientRealHeight; to: height}
        NumberAnimation { target: kwinClientThumbnail; property: "width"; from: kwinClientThumbnail.clientRealWidth; to: width}
      }
    }
  }*/

  Item {
    id: actualThumbnail
    visible: false
    //flags: Qt.WA_TranslucentBackground | Qt.X11BypassWindowManagerHint
    opacity: 1
    //color: '#00000000'
    x: -2
    y: -2
    Behavior on height { NumberAnimation { duration: 250 } }
    Behavior on width { NumberAnimation { duration: 250 } }
    Behavior on x { NumberAnimation { duration: 250 } }
    Behavior on y { NumberAnimation { duration: 250 } }
    clip: false
    scale: 1
    KWinLib.ThumbnailItem {
      // Basically, this 'fills up' to the parent object, so we encapsulate it
      // so that we can shrink the thumbnail without messing with the grid itself.
      id: kwinThumbnailRenderWindow
      anchors.fill: actualThumbnail
      //anchors.fill: parent
      property var multi: ((clientRealWidth*clientRealHeight)/(dashboard.screenWidth*(dashboard.screenHeight+dashboard.dockHeight)))
      //anchors.fill: kwinClientThumbnail
      //wId: workspace.clientList()[clientId].windowId
      wId: kwinClientThumbnail.clientId
      //height: kwinClientThumbnail.height // multi
      //width: kwinClientThumbnail.width // multi
      height: actualThumbnail.height
      width: actualThumbnail.width
      //height: kwinClientThumbnail.clientRealHeight
      //width: kwinClientThumbnail.clientRealWidth
      //clipTo: kwinClientThumbnail
      //saturation: 1
      //scale: 1
      x: 0 //-kwinClientThumbnail.mapToGlobal(parent.x,parent.y).x
      y: 0 //-kwinClientThumbnail.mapToGlobal(parent.x,parent.y).y
      z: 0
      visible: false
      clip: false
    }
    Rectangle {
      id: thumbnailBackgroundRectangle
      // This is a test rectangle.  Ultimately, I'd like to show this when compositing is off.
      anchors.fill: parent
      //anchors.fill kwinClientThumbnail
      color: 'black'
      opacity: 0.5
      scale: 1
      visible: true
      clip: true
    }
    Rectangle {
      // This is a background rectangle useful for highlighting the item under the mouse.
      id: hoverRectangle
      anchors.fill: parent
      color: 'white'
      opacity: 0
      visible: false
      scale: 1
      clip: true
      height: kwinClientThumbnail.height+4
      width: kwinClientThumbnail.width+4
      Behavior on opacity {
        NumberAnimation {
           duration: 250
          }
      }
    }
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
      to: 100
      duration: 100
    }
    PropertyAnimation {
      target: actualThumbnail
      //target: kwinClientThumbnail
      property: "width"
      to: 100*dashboard.screenRatio
      duration: 100
  }

    PropertyAnimation { target: actualThumbnail; property: "x"; to: shrinkAnim.animX-(dash.gridHeight/2*dashboard.screenRatio); duration: 100}
    PropertyAnimation { target: actualThumbnail; property: "y"; to: shrinkAnim.animY-dash.gridHeight/2; duration: 100}


    onStopped: {
      mouseArea.enabled = true;
      kwinClientThumbnail.isSmall = true;
    }
  }
  ParallelAnimation {
    id: growthAnim
    alwaysRunToEnd: false
    running: false
    property int animX: 0
    property int animY: 0
    NumberAnimation { target: actualThumbnail; property: "height"; to: originalHeight-2; duration: 100}
    NumberAnimation { target: actualThumbnail; property: "width"; to: originalWidth-2; duration: 100}
    PropertyAnimation { target: actualThumbnail; property: "x"; to: 2; duration: 100}
    PropertyAnimation { target: actualThumbnail; property: "y"; to: 2; duration: 100}


    onStopped: {
      mouseArea.enabled = true;
      kwinClientThumbnail.isSmall = false;
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
      if (currentDesktop == workspace.currentDesktop) {
        dashboard.toggleBoth();
      }
      workspace.activeClient = clientObject;
    }

    onEntered: {
      // Show a rectangle!
      hoverRectangle.visible = true;
      hoverRectangle.opacity = 0.95;
    }
    onExited: {
      hoverRectangle.visible = false;
      hoverRectangle.opacity = 0;
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
      //console.log(Drag.hotSpot);
      //if (actualThumbnail.height != dash.gridHeight) {
      if (kwinClientThumbnail.state == 'isHeld') {
        shrinkAnim.restart()
      }
    }

    onPressed: {
      // Sets things up for the return animation.
      kwinClientThumbnail.originalX = kwinClientThumbnail.x;
      kwinClientThumbnail.originalY = kwinClientThumbnail.y;
      kwinClientThumbnail.originalZ = kwinClientThumbnail.z;
      kwinClientThumbnail.clientObject.keepAbove = true;
      // So doesn't work.
      //kwinClientThumbnail.z = 1000+kwinClientThumbnail.z;
      kwinClientThumbnail.state = 'isHeld';
      // This works!
      //kwinClientThumbnail.Drag.hotSpot.x = mouse.x-(dash.gridHeight/2*dashboard.screenRatio);
      //kwinClientThumbnail.Drag.hotSpot.y = mouse.y-dash.gridHeight/2;
      //kwinClientThumbnail.Drag.hotSpot.x = mouse.x;
      //kwinClientThumbnail.Drag.hotSpot.y = mouse.y;
      kwinClientThumbnail.newDesktop = kwinClientThumbnail.currentDesktop;
      kwinClientThumbnail.currentDesktop = kwinClientThumbnail.newDesktop;
      //kwinClientThumbnail.oldParent = littleDesktopRepeater.itemAt(kwinClientThumbnail.clientObject.desktop-1).children[2].children[0];
      //kwinClientThumbnail.parent = dragHolder;
      //kwinClientThumbnail.();
      console.log('BLAHBLAHBLAH');
    }
    onReleased: {
      kwinClientThumbnail.state = 'notHeld';
      kwinClientThumbnail.clientObject.keepAbove = false;
      console.log(Drag.drop());
      console.log('TESTING');
      console.log(kwinClientThumbnail.newDesktop);
      console.log(kwinClientThumbnail.newActivity);
      // Let's see if the dropArea can handle this.
      if (kwinClientThumbnail.isSmall) {
        growthAnim.restart();
        //updateSize(kwinClientThumbnail.originalHeight, kwinClientThumbnail.originalWidth);
        kwinClientThumbnail.isSmall = false;
      }
      //console.log()
      //kwinClientThumbnail.clientObject.setOnActivities(kwinClientThumbnail.newActivity);
      //console.log(Object.getOwnPropertyNames(kwinClientThumbnail.clientObject));
      //console.log(Object.getOwnPropertyNames(ActivitySwitcher))
      if (kwinClientThumbnail.clientObject.activities != kwinClientThumbnail.newActivity) {
        //kwinClientThumbnail.clientObject.setActivity(kwinClientThumbnail.newActivity);
        // This is a read-only property, and so we're unable to change it from here.
        // Not sure if there's a model out there that would let us do it.
        console.log(Object.getOwnPropertyNames(kwinClientThumbnail.clientObject));
        //kwinClientThumbnail.clientObject.activities = kwinClientThumbnail.newActivity;
        // for now, since we can't sort it.
        var activityModel = console.log(Object.getOwnPropertyNames(Activities.ResourceInstance));
        console.log(kwinClientThumbnail.clientObject.activities);
        //returnAnim.running = true;
        kwinClientThumbnail.x = kwinClientThumbnail.originalX;
        kwinClientThumbnail.y = kwinClientThumbnail.originalY;
      } else if (kwinClientThumbnail.clientObject.desktop == kwinClientThumbnail.newDesktop ) {
        //console.log(newDesktop);
        //returnAnim.running = true;
        //growthAnim.running = true;
        kwinClientThumbnail.x = kwinClientThumbnail.originalX;
        kwinClientThumbnail.y = kwinClientThumbnail.originalY;
      } else if (newDesktop == 0) {
        //returnAnim.running = true;
        growthAnim.running = true;
        //updateSize(kwinClientThumbnail.originalHeight, kwinClientThumbnail.originalWidth);
        kwinClientThumbnail.x = kwinClientThumbnail.originalX;
        kwinClientThumbnail.y = kwinClientThumbnail.originalY;
      } else {
        kwinClientThumbnail.currentDesktop = kwinClientThumbnail.newDesktop;
        kwinClientThumbnail.clientObject.desktop = kwinClientThumbnail.newDesktop;
        // We need to make it invisible, as well.
        //kwinClientThumbnail.visible = false;
        //returnAnim.running = true;
        kwinClientThumbnail.x = kwinClientThumbnail.originalX;
        kwinClientThumbnail.y = kwinClientThumbnail.originalY;
        kwinClientThumbnail.z = kwinClientThumbnail.originalZ;
        // We want the others to pop up, so.
      }
    }
  }

  Component.onCompleted: {
    // We just check to see whether we're on the current desktop.
    // If not, don't show it.
    //moveToThumbnail.running = false;
    growthAnim.running = false;
    //moveFromThumbnail.running = false;
    shrinkAnim.running = false;
    clientObject.desktopChanged.connect(callUpdateGrid);
    clientObject.activitiesChanged.connect(callUpdateGrid);
    // It seems that occasionally, this might not fire off.  Unsure as to why.
    workspace.currentActivityChanged.connect(callUpdateGrid);
    mainBackground.onStateChanged.connect(toggleVisible);
    // We just need to make sure we're calling correct parent signals when
    // the desktop changes.  This avoids crashes upon creating/removing new desktops!
    workspace.numberDesktopsChanged.connect(callUpdateGrid);
    workspace.currentDesktopChanged.connect(callUpdateGrid);
    workspace.clientRemoved.connect(disconnectAllSignals);
    //searchFieldAndResults.children[1].forceActiveFocus();
    callUpdateGrid();
  }

  function disconnectAllSignals(c) {
    console.log(c);
    if (c) {
      if (c.windowId == kwinClientThumbnail.clientId) {
        console.log('KILLING MYSELF');
        // Yes, we even have to disconnect this.
        workspace.clientRemoved.disconnect(disconnectAllSignals);
        workspace.numberDesktopsChanged.disconnect(callUpdateGrid);
        workspace.currentDesktopChanged.disconnect(callUpdateGrid);
        mainBackground.onStateChanged.disconnect(callUpdateGrid);
        //dashboard.onStateChanged.disconnect(callUpdateGrid);
        clientObject.desktopChanged.disconnect(callUpdateGrid);
        clientObject.activitiesChanged.disconnect(callUpdateGrid);
        workspace.currentActivityChanged.disconnect(callUpdateGrid);
        kwinClientThumbnail.destroy();
      }
    }
  }

  function updateSize(height, width) {
    var scale = (clientRealWidth/clientRealHeight);
    //var multi = ((clientRealWidth*clientRealHeight)/(dashboard.screenWidth*(dashboard.screenHeight+dashboard.dockHeight)));
    var multi = 1;
    if (kwinClientThumbnail.isLarge) {
      if (height <= clientRealHeight) {
        kwinClientThumbnail.height = height;// - 4;
        kwinClientThumbnail.width = (height * scale);// - 4;
        kwinClientThumbnail.originalHeight = height;// - 4;
        kwinClientThumbnail.originalWidth = (height * scale);// - 4;
        actualThumbnail.height = (height) + 4;// - 4;
        actualThumbnail.width = (height * scale) + 4;// - 4;
        //actualThumbnail.height = (dashboard.screenHeight) * multi;// - 4;
        //actualThumbnail.width = (dashboard.screenWidth) * multi;// - 4;
      } else {
        kwinClientThumbnail.height = clientRealHeight-12;
        kwinClientThumbnail.width = (clientRealHeight-12) * scale;
        kwinClientThumbnail.originalHeight = clientRealHeight - 12;
        kwinClientThumbnail.originalWidth = (clientRealHeight-12) * scale;
        actualThumbnail.height = clientRealHeight + 4 - 12;
        actualThumbnail.width = (clientRealHeight * scale) + 4;
      }
    } else {
      kwinClientThumbnail.height = height;// - 4;
      kwinClientThumbnail.width = (height * scale);// - 4;
      kwinClientThumbnail.originalHeight = height;// - 4;
      kwinClientThumbnail.originalWidth = (height * scale);// - 4;
      actualThumbnail.height = (height);// - 4;
      actualThumbnail.width = (height * scale);// - 4;
    }
  }

  function toggleVisible(state) {
    if (state == 'visible') {
      //runMoveToThumbnailAnim();
      // only toggle the ones on the current activity.
      if (kwinClientThumbnail.clientObject.activities == workspace.currentActivity || kwinClientThumbnail.clientObject.activities == '') {
        kwinThumbnailRenderWindow.wId = kwinClientThumbnail.clientId;
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

  function resizeToLarge() {
    kwinClientThumbnail.x = kwinClientThumbnail.clientRealX; //- (kwinClientThumbnail.currentDesktop*(dashboard.screenWidth+10));
    kwinClientThumbnail.y = kwinClientThumbnail.clientRealY;
    console.log(kwinClientThumbnail.clientRealX);
    console.log('ABOVE ME');
    updateSize(kwinClientThumbnail.clientRealHeight, kwinClientThumbnail.clientRealWidth);
    //kwinClientThumbnail.width = kwinClientThumbnail.clientRealWidth;
    //kwinClientThumbnail.height = kwinClientThumbnail.clientRealHeight;
  }

    function callUpdateGrid() {
      // It seems that when we move a large to a small and vice versa, we don't
      // always properly trigger updates.
      // Actually, it seems we don't update our new parent properly.  WHAT.
      console.log('client!');
      console.log(Object.getOwnPropertyNames(kwinClientThumbnail.clientObject));
      // First, update the client size.
      kwinClientThumbnail.clientRealX = kwinClientThumbnail.clientObject.x;
      kwinClientThumbnail.clientRealY = kwinClientThumbnail.clientObject.y;
      kwinClientThumbnail.clientRealHeight = workspace.clientList()[cId].height;
      kwinClientThumbnail.clientRealWidth = workspace.clientList()[cId].width;
      if ((kwinClientThumbnail.clientObject.activities == workspace.currentActivity || kwinClientThumbnail.clientObject.activities == '')) {
        if (kwinClientThumbnail.isLarge) {
          //kwinClientThumbnail.toggleVisible('visible');
          if (kwinClientThumbnail.currentDesktop == workspace.currentDesktop) {
            //kwinClientThumbnail.clientObject.noBorder = true;
            kwinClientThumbnail.toggleVisible('visible');
          } else {
            //kwinClientThumbnail.clientObject.noBorder = kwinClientThumbnail.noBorder;
          }
          if (kwinClientThumbnail.clientObject.desktop > -1) {
            //if (kwinClientThumbnail.currentDesktop == workspace.currentDesktop) {
              kwinClientThumbnail.parent = currentDesktopGrid.itemAt(kwinClientThumbnail.clientObject.desktop-1).children[1].children[0];
              // Now we'll try and adjust for the whole... thing.
              kwinClientThumbnail.clientRealWidth = kwinClientThumbnail.clientObject.width;
              kwinClientThumbnail.clientRealHeight = kwinClientThumbnail.clientObject.height;
              kwinClientThumbnail.resizeToLarge();
              currentDesktopGrid.itemAt(kwinClientThumbnail.clientObject.desktop-1).children[1].updateGrid();
          }
        } else {
          if (kwinClientThumbnail.clientObject.desktop > -1) {
            kwinClientThumbnail.currentDesktop = kwinClientThumbnail.clientObject.desktop;
            // CHANGE THIS FOR AN OPTION TO NOT HIDE THINGS
            if (kwinClientThumbnail.currentDesktop != workspace.currentDesktop) {
              //kwinClientThumbnail.clientObject.noBorder = true;
              kwinClientThumbnail.toggleVisible('visible');
            } else {
              //kwinClientThumbnail.toggleVisible('invisible');
              //kwinClientThumbnail.clientObject.noBorder = kwinClientThumbnail.noBorder;
            }
            kwinClientThumbnail.parent = littleDesktopRepeater.itemAt(kwinClientThumbnail.clientObject.desktop-1).children[2].children[0];
            littleDesktopRepeater.itemAt(kwinClientThumbnail.clientObject.desktop-1).children[2].updateGrid();
            //littleDesktopRepeater.itemAt(kwinClientThumbnail.clientObject.desktop-1).children[2].children[0].updateGrid();
            //var p = littleDesktopRepeater.itemAt(kwinClientThumbnail.clientObject.desktop-1).children[2].children[0];
            //littleDesktopRepeater.itemAt(kwinClientThumbnail.clientObject.desktop-1).children[2].updateGrid();
            //kwinClientThumbnail.height = p.height  / p.rows;
            //kwinClientThumbnail.width = p.width  / p.columns;
            //console.log(p.height);
          }
        }
      } else {
        console.log('REPARENTING');
        console.log('MAKE ME INVISIBLE');
        kwinClientThumbnail.visible = false;
        actualThumbnail.visible = false;
        //kwinClientThumbnail.clientObject.noBorder = kwinClientThumbnail.noBorder;
        //kwinClientThumbnail.parent = desktopThumbnailGrid;
      }
    }

    function _overlapsDesktop(x, y) {
      // Here, we're going to determine if we're in a new desktop.
      //console.log(x, y);
      // If we drag it out of the bar, send it to the current desktop.
      if (y > dash.gridHeight) {
        console.log('Baby bitch');
        console.log(workspace.currentDesktop);
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

}
