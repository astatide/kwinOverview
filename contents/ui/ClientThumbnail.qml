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

  // This seems to be necessary to set everything appropriately.  Not 100% sure why.
  property int scale: 1
  property var cId: 0
  property var client: ''
  property string clientId: "0"
  property var currentDesktop: 0
  property var newDesktop: 0
  property var newActivity: 0
  property var oldParent: 0
  Drag.active: mouseArea.drag.active
  //Layout.fillHeight: true
  //Layout.fillWidth: true

  // Ha ha!
  opacity: 0.5

  // This is for moving the thumbnail back
  property int originalX: 0
  property int originalY: 0
  // This is for moving to our thumbnail position and size.
  property int clientRealX: 0
  property int clientRealY: 0
  property int clientRealWidth: 0
  property int clientRealHeight: 0
  property var noBorder: false
  //x: 0
  //y: 0
  //z: 0
  property int originalZ: 0

  //property bool isHeld: false
  property bool isSmall: false
  property bool isLarge: false

  //height: 100 //parent.height
  //width: 100 //parent.width

  // For the mouse.
  property QtObject container

  Rectangle {
    // This is a background rectangle useful for highlighting the item under the mouse.
    id: hoverRectangle
    anchors.fill: parent
    color: 'black'
    opacity: 0.5
    visible: true
    scale: 1
    clip: true
    //height: 100
    //width: 100
    Behavior on opacity {
      NumberAnimation {
         duration: 250
        }
    }
  }

  onWidthChanged: {
    //setSize();
  }
  onHeightChanged: {
    //setSize();
  }

  onClientChanged: {
    //console.log('our client has changed');
    //kwinThumbnailRenderWindow.wId = kwinClientThumbnail.client.internalId;
  }

  Item {
    id: actualThumbnail
    visible: true
    opacity: 1
    x: 2
    y: 2
    //Behavior on height { NumberAnimation { duration: 1000 } }
    //Behavior on width { NumberAnimation { duration: 1000 } }
    //Behavior on x { NumberAnimation { duration: 100 } }
    //Behavior on y { NumberAnimation { duration: 100 } }
    clip: true
    scale: 1
    //anchors.fill: kwinClientThumbnail
    //height: 100
    //width: 100
    height: kwinClientThumbnail.height
    width: kwinClientThumbnail.width

    KWinLib.ThumbnailItem {
      // Basically, this 'fills up' to the parent object, so we encapsulate it
      // so that we can shrink the thumbnail without messing with the grid itself.
      id: kwinThumbnailRenderWindow
      anchors.fill: actualThumbnail
      //client: kwinClientThumbnail.client
      wId: kwinClientThumbnail.client.internalId
      visible: true
      clip: true
    }

    Rectangle {
      id: thumbnailBackgroundRectangle
      // This is a test rectangle.  Ultimately, I'd like to show this when compositing is off.
      anchors.fill: parent
      //height: 100
      //width: 100
      color: 'black'
      opacity: 0.5
      scale: 1
      visible: false
      clip: true
    }
  }

  function setSize() {
    console.log("CHANGING ME HEIGHT YA BASTICH");
    actualThumbnail.width = kwinClientThumbnail.width;
    actualThumbnail.height = kwinClientThumbnail.height;
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
      workspace.activeClient = kwinClientThumbnail.client;
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
    }

    onPressed: {
      kwinClientThumbnail.originalX = kwinClientThumbnail.x;
      kwinClientThumbnail.originalY = kwinClientThumbnail.y;
    }
    onReleased: {
      parent.Drag.drop();
      kwinClientThumbnail.x = kwinClientThumbnail.originalX;
      kwinClientThumbnail.y = kwinClientThumbnail.originalY;
      
    }
  }

  Component.onCompleted: {
    // We just check to see whether we're on the current desktop.
    // If not, don't show it.
    //moveToThumbnail.running = false;
    //growthAnim.running = false;
    //moveFromThumbnail.running = false;
    //shrinkAnim.running = false;
    //clientObject.desktopChanged.connect(callUpdateGrid);
    //clientObject.activitiesChanged.connect(callUpdateGrid);
    //kwinClientThumbnail.onParentChanged.connect(callUpdateGrid);
    // It seems that occasionally, this might not fire off.  Unsure as to why.
    //workspace.currentActivityChanged.connect(callUpdateGrid);
    //mainBackground.onStateChanged.connect(callUpdateGrid);
    // We just need to make sure we're calling correct parent signals when
    // the desktop changes.  This avoids crashes upon creating/removing new desktops!
    //workspace.numberDesktopsChanged.connect(callUpdateGrid);
    //workspace.currentDesktopChanged.connect(callUpdateGrid);
    //kwinClientThumbnail.client.desktopChanged.connect(setVisible);
    //workspace.clientRemoved.connect(disconnectAllSignals);
    //kwinClientThumbnail.toggleVisible('invisible');
    //searchFieldAndResults.children[1].forceActiveFocus();
    //callUpdateGrid();
  }

  function setVisible() {
    console.log('AH YEAH');
    
  }

  function disconnectAllSignals(c) {
    //console.log(c);
    if ( kwinClientThumbnail != null) {
      if (c.internalId == kwinClientThumbnail.client.internalId) {
        //console.log('KILLING MYSELF');
        // Yes, we even have to disconnect this.
        workspace.clientRemoved.disconnect(disconnectAllSignals);
        //kwinClientThumbnail.onParentChanged.disconnect(callUpdateGrid);
        //workspace.numberDesktopsChanged.disconnect(callUpdateGrid);
        //workspace.currentDesktopChanged.disconnect(callUpdateGrid);
        //mainBackground.onStateChanged.disconnect(callUpdateGrid);
        //dashboard.onStateChanged.disconnect(callUpdateGrid);
        //clientObject.desktopChanged.disconnect(callUpdateGrid);
        //clientObject.activitiesChanged.disconnect(callUpdateGrid);
        //workspace.currentActivityChanged.disconnect(callUpdateGrid);
        //kwinClientThumbnail.parent = 
        //kwinClientThumbnail.destroy();
      }
    }
  }

}
