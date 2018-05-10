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
  id: kwinDesktopThumbnailContainer
  property int desktop: 0
  x: 0
  y: 0

  Grid {
    id: clientGridLayout
    visible: true
    x: 0
    y: 0

    anchors.verticalCenter: parent.verticalCenter
    rows: { return _returnMatrixSize() }
    // No order guaranteed, here.
    columns: { return _returnMatrixSize() }

    function _overlapsDesktop(x, y) {
      // Here, we're going to determine if we're in a new desktop.
      //console.log(workspace.currentDesktop);
      //console.log(x, y);
      // If we drag it out of the bar, send it to the current desktop.
      if (y > dash.height) {
        return workspace.currentDesktop;
      }
      for (var d = 1; d <= workspace.desktops; d++) {
        // We need to check if we're within the new bounds.  That's height and width!
        // or just width, actually.
        // x and y are now global coordinates.
        // We have workspace.desktops, and our screen width is activeScreen.width
        //console.log(x, (d)*kwinDesktopThumbnailContainer.width + desktopThumbnailGridBackgrounds.width/(workspace.desktops) + dash.height*main.screenRatio, d);
        if (x < (d)*kwinDesktopThumbnailContainer.width + desktopThumbnailGridBackgrounds.width/(workspace.desktops) + dash.height*dashboard.screenRatio) {
          return d-1
        }
        //if (x > (d-1*width)+activeScreen.width/(2*workspace.desktops)) {
        //  return d;
        //}
      }
      return 0;

    }

    function _onDesktop() {
      var c;
      var oD = 0;
      for (c = 0; c < workspace.clientList().length; c++) {
        if (workspace.clientList()[c].desktop-1 == desktop) {
          oD++;
        }
      }
      if (clientGridLayout.onDesktop == 0) {
        oD = 1;
      }
      return oD;
    }

    function _returnMatrixSize() {
      // Figure out how many we have on the desktop, then calculate an
      // an appropriate row x column size.
      var oD = _onDesktop();
      // Just do it manually for the moment; not elegant, but effective.
      // Not sure what math library I'd need and I'm feeling lazy.
      if (oD <= 1)
        return 1
      if (oD <= 4)
        return 2
      if (oD <= 9)
        return 3
      if (oD <= 16)
        return 4
      if (oD < 25)
        return 5
      return 36
    }

    Repeater {
      // Now, we build up our windows.
      model: workspace.clientList().length
      Item {
        id: kwinClientThumbnail
        visible: true
        // We need to dynamically set these.
        property int originalWidth: kwinDesktopThumbnailContainer.width / clientGridLayout.columns
        property int originalHeight: kwinDesktopThumbnailContainer.height / clientGridLayout.columns
        property int scale: kwinDesktopThumbnailContainer.height / (kwinDesktopThumbnailContainer.width)
        // Setting the height/width seems to break EVERYTHING, as the thumbnails are busted.
        //width: kwinDesktopThumbnailContainer.width / clientGridLayout.columns
        //height: kwinDesktopThumbnailContainer.height / clientGridLayout.columns
        // Get our actual client information.  This way, we can move through desktops/activities.
        property var clientObject: { workspace.clientList()[model.index] }
        //anchors.fill: parent

        opacity: 0

        // This is for moving the thumbnail back
        property int originalX: 0
        property int originalY: 0
        // This is for moving to our thumbnail position and size.
        property int clientRealX: { workspace.clientList()[model.index].x }
        property int clientRealY: { workspace.clientList()[model.index].y }
        property int clientRealWidth: { workspace.clientList()[model.index].width }
        property int clientRealHeight: {workspace.clientList()[model.index].height }
        x: 0
        y: 0
        z: 0
        property int originalZ: 0

        property bool isHeld: false

        // Connect to the client signal.
        //signal desktopChanged: { return workspace.clientList()[model.index].desktopChanged }

        // Are THESE breaking it?  What the shit.
        // These DO seem to break it!  What the fuck.
        // Something about the way they're painted, maybe?  Not so good.
        KWinLib.ThumbnailItem {
          id: actualThumbnail
          //anchors.verticalCenter: parent.verticalCenter
          anchors.fill: parent
          wId: workspace.clientList()[model.index].windowId
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
          NumberAnimation { target: kwinClientThumbnail; property: "height"; from: clientRealHeight; to: originalHeight; easing.amplitude: 2; easing.type: Easing.InOutQuad; duration: 1000}
          NumberAnimation { target: kwinClientThumbnail; property: "width"; from: clientRealWidth; to: originalWidth; easing.amplitude: 2; easing.type: Easing.InOutQuad; duration: 1000}
          //NumberAnimation { target: kwinClientThumbnail; property: "x"; from: clientRealX; to: kwinClientThumbnail.originalX; easing.amplitude: 2; easing.type: Easing.InOutQuad; duration: 1000}
          //NumberAnimation { target: kwinClientThumbnail; property: "y"; from: clientRealY; to: kwinClientThumbnail.originalY; easing.amplitude: 2; easing.type: Easing.InOutQuad; duration: 1000}
          NumberAnimation { target: kwinClientThumbnail; property: "x"; from: kwinDesktopThumbnailContainer.mapFromGlobal(clientRealX, clientRealY).x; to: kwinClientThumbnail.originalX; easing.amplitude: 2; easing.type: Easing.InOutQuad; duration: 1000}
          NumberAnimation { target: kwinClientThumbnail; property: "y"; from: kwinDesktopThumbnailContainer.mapFromGlobal(clientRealX, clientRealY).y; to: kwinClientThumbnail.originalY; easing.amplitude: 2; easing.type: Easing.InOutQuad; duration: 1000}
          //NumberAnimation { target: kwinClientThumbnail; property: "x"; from: kwinClientThumbnail.mapFromGlobal(clientRealX, clientRealY).x; to: kwinClientThumbnail.x; easing.amplitude: 2; easing.type: Easing.InOutQuad; duration: 5000}
          //NumberAnimation { target: kwinClientThumbnail; property: "y"; from: kwinClientThumbnail.mapFromGlobal(clientRealX, clientRealY).y; to: kwinClientThumbnail.y; easing.amplitude: 2; easing.type: Easing.InOutQuad; duration: 5000}
          //NumberAnimation { target: actualThumbnail; property: "width"; from: width; to: width*2}
          //NumberAnimation { target: actualThumbnail; property: "height"; from: height; to: height*2}
        }
        ParallelAnimation {
          id: moveFromThumbnail
          NumberAnimation { target: kwinClientThumbnail; property: "height"; to: clientRealHeight; from: originalHeight}
          NumberAnimation { target: kwinClientThumbnail; property: "width"; to: clientRealWidth; from: originalWidth}
          NumberAnimation { target: kwinClientThumbnail; property: "x"; to: clientRealX; from: kwinClientThumbnail.originalX}
          NumberAnimation { target: kwinClientThumbnail; property: "y"; to: clientRealY; from: kwinClientThumbnail.originalY}
        }
        ParallelAnimation {
          id: growthAnim
          NumberAnimation { target: kwinClientThumbnail; property: "height"; from: originalHeight; to: originalHeight*2}
          NumberAnimation { target: kwinClientThumbnail; property: "width"; from: originalWidth; to: originalWidth*2}
          //NumberAnimation { target: actualThumbnail; property: "width"; from: width; to: width*2}
          //NumberAnimation { target: actualThumbnail; property: "height"; from: height; to: height*2}
        }
        ParallelAnimation {
          id: shrinkAnim
          NumberAnimation { target: kwinClientThumbnail; property: "height"; from: height; to: originalHeight}
          NumberAnimation { target: kwinClientThumbnail; property: "width"; from: width; to: originalWidth}
          //NumberAnimation { target: actualThumbnail; property: "width"; from: width; to: width/2}
          //NumberAnimation { target: actualThumbnail; property: "height"; from: height; to: height/2}
        }
        ParallelAnimation on width {
          id: newShrinkAnim
          NumberAnimation { target: kwinClientThumbnail; property: "height"; from: originalHeight; to: height}
          NumberAnimation { target: kwinClientThumbnail; property: "width"; from: originalWidth; to: width}
          //NumberAnimation { target: actualThumbnail; property: "width"; from: width; to: width/2}
          //NumberAnimation { target: actualThumbnail; property: "height"; from: height; to: height/2}
        }
        ParallelAnimation {
          id: returnAnim
          NumberAnimation { target: kwinClientThumbnail; property: "x"; from: x; to: kwinClientThumbnail.originalX}
          NumberAnimation { target: kwinClientThumbnail; property: "y"; from: y; to: kwinClientThumbnail.originalY}
          //NumberAnimation { target: actualThumbnail; property: "width"; from: width; to: width/2}
          //NumberAnimation { target: actualThumbnail; property: "height"; from: height; to: height/2}
        }
        ParallelAnimation {
          id: growFromNothing
          NumberAnimation { target: kwinClientThumbnail; property: "height"; from: 0; to: originalHeight}
          NumberAnimation { target: kwinClientThumbnail; property: "width"; from: 0; to: originalWidth}
          NumberAnimation { target: thumbnailBackgroundRectangle; property: "height"; from: 0; to: kwinClientThumbnail.originalHeight}
          NumberAnimation { target: thumbnailBackgroundRectangle; property: "width"; from: 0; to: kwinClientThumbnail.originalWidth}
          //NumberAnimation { target: actualThumbnail; property: "width"; from: width; to: width*2}
          //NumberAnimation { target: actualThumbnail; property: "height"; from: height; to: height*2}
        }
        ParallelAnimation {
          id: shrinkToNothing
          NumberAnimation { target: kwinClientThumbnail; property: "height"; from: height; to: 0}
          NumberAnimation { target: kwinClientThumbnail; property: "width"; from: width; to: 0}
          NumberAnimation { target: thumbnailBackgroundRectangle; property: "height"; from: height; to: 0}
          NumberAnimation { target: thumbnailBackgroundRectangle; property: "width"; from: width; to: 0}
          //NumberAnimation { target: actualThumbnail; property: "width"; from: width; to: width*2}
          //NumberAnimation { target: actualThumbnail; property: "height"; from: height; to: height*2}
        }


        MouseArea {
          id: mouseArea
          anchors.fill: parent
          drag.axis: 'XAndYAxis'
          drag.target: kwinClientThumbnail
          hoverEnabled: true
          //drag.maximumX: clientGridLayout.width
          //onClicked: {
          //  console.log(mouse);
          //  if (kwinClientThumbnail.isHeld == false) {
          //    actualThumbnail.visible = !actualThumbnail.visible;
          //  }
          //}
          onClicked: {
            workspace.activeClient = clientObject;
            dashboard.toggleBoth();
          }
          onPressed: {
            kwinClientThumbnail.originalX = kwinClientThumbnail.x;
            kwinClientThumbnail.originalY = kwinClientThumbnail.y;
            // Draw above everything else!
            kwinClientThumbnail.originalZ = kwinClientThumbnail.z;
            kwinClientThumbnail.z = 1000;
            kwinClientThumbnail.isHeld = true;
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
            if (clientObject.desktop == newDesktop ) {
              //console.log(newDesktop);
              returnAnim.running = true;
            } else if (newDesktop == 0) {
              returnAnim.running = true;
            } else {
              clientObject.desktop = newDesktop;
              // We need to make it invisible, as well.
              kwinClientThumbnail.visible = false;
              returnAnim.running = true;
              kwinClientThumbnail.z = kwinClientThumbnail.originalZ;
              // We want the others to pop up, so.
            }
          }
        }

        function setVisible() {
          if (workspace.clientList()[model.index].desktop-1 == desktop) {
            kwinClientThumbnail.visible = true;
            //actualThumbnail.visible = true;
          } else {
            kwinClientThumbnail.visible = false;
            //actualThumbnail.visible = false;
          }
          //growFromNothing.running = true;
        }

        function runAnimations() {
          if (visible) {
            if (mainBackground.state == 'visible') {
              kwinClientThumbnail.originalX = kwinClientThumbnail.x;
              kwinClientThumbnail.originalY = kwinClientThumbnail.y;
              moveToThumbnail.running = true;
            } else {
              moveFromThumbnail.running = true;
            }
          }
        }

        Component.onCompleted: {
          // We just check to see whether we're on the current desktop.
          // If not, don't show it.
          setVisible();
          // WHY DOES THIS FIX IT?
          shrinkToNothing.running = false;
          growFromNothing.running = false;
          moveToThumbnail.running = false;
          moveFromThumbnail.running = false;
          workspace.clientList()[model.index].desktopChanged.connect(setVisible);
          mainBackground.stateChanged.connect(runAnimations)
          workspace.currentDesktopChanged.connect(updateGrid);
        }

          function updateGrid(i, client) {
            // Probably won't work.
            kwinDesktopThumbnailContainer.desktop = workspace.currentDesktop-1;
            // But we actually need to rebuild the whole grid.  Huh!
            clientGridLayout.rows = clientGridLayout._returnMatrixSize();
            clientGridLayout.columns = clientGridLayout._returnMatrixSize();
            width = kwinDesktopThumbnailContainer.width / clientGridLayout.columns;
            height = kwinDesktopThumbnailContainer.height / clientGridLayout.columns;
            //clientGridLayout.height = dashboard.screenHeight - dash.height - 30
            //width: (dashboard.screenHeight - dash.height - 30)*dashboard.screenRatio
            //clientGridLayout.width = dashboard.screenWidth
            setVisible();
          }
      }
    }
  }
}
