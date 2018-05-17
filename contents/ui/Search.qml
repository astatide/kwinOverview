// A lot of this was taken directly from the Search plasmoid shipped with
// KDE, so all credit should go there.  Therefore, that's also how the licensing
// should be handled.

import QtQuick 2.7
import QtQuick.Layouts 1.1

import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import org.kde.milou 0.1 as Milou

import org.kde.plasma.components 2.0 as PlasmaComponents

Item {
  id: mainSearch

  // Why aren't we using plasma?
  // 1. We're not a plasmoid.
  // 2. I would like this to be as 'portable' as possible,
  // to main the strength of KWin not being tied to Plasma.
  // While I already break that rule with the inclusion (and rather extensive)
  // use of activities, I do hope to be able to make that something optional.

  Rectangle {
    width: dashboard.screenWidth/2
    anchors.horizontalCenter: parent.horizontalCenter
    height: searchField.height
    opacity: 0.5
    color: 'black'
  }

  /*Keys.onPressed: {
    console.log(JSON.stringify(event.key));
    console.log('WHEEEE');
    searchField.forceActiveFocus();
    //searchFieldAndResults.focus = true;
    //searchField.text = ""
    //currentDesktopGrid.visible = !currentDesktopGrid.visible;
  }*/

  PlasmaComponents.TextField {
      id: searchField
      signal searchTextChanged()
      width: dashboard.screenWidth/2
      anchors.horizontalCenter: parent.horizontalCenter
      // I would LIKE for this to all work, but heeeey....
      focus: true
      style: TextFieldStyle {
        textColor: '#a89984'
        font.bold: true
        background: Rectangle {
          //radius: 2
          opacity: 1
          color: 'transparent'
          implicitWidth: 100
          implicitHeight: 24
          //border.color: "#333"
          //border.width: 1
          /*Rectangle {
            color: 'black'
            border.color: 'black'
            radius: 1
            height: 1
            width: searchField.width
            anchors.top: parent.bottom
          }*/
        }
      }
      /*onSearchTextChanged: {
          listView.setQueryString(text)
      }*/
      Timer {
        id: timer
        interval: 200
        //onTriggered: TextField.searchTextChanged()
        onTriggered: {
          // Fade out the bigDesktopRepeater opacity
          console.log('yay!');
          listView.setQueryString(searchField.text)
          // Not sure why this doesn't work, but hey.
          //currentDesktopGrid.visible = !currentDesktopGrid.visible;
          // This propery enables and disables the large grid clients.
          if (searchField.text == '') {
            mainSearch.visible = false;
            currentDesktopGridThumbnailContainer.state = 'showDesktop';
            //searchField.focus = false;
          } else {
            mainSearch.visible = true;
            currentDesktopGridThumbnailContainer.state = 'showSearch';
          }
          searchField.forceActiveFocus()
        }
      }

      onTextChanged: {
        if (searchField.text == '') {
          mainSearch.visible = false;
          //currentDesktopGridThumbnailContainer.state = 'showDesktop';
          //searchField.focus = false;
        } else {
          mainSearch.visible = true;
          //currentDesktopGridThumbnailContainer.state = 'showSearch';
        }
        timer.restart()
      }

      /*MouseArea {
        anchors.fill: parent
        onClicked: {
          // we really just want to make sure that when we click here,
          // our qml window has focus.
          //dashboard.requestActivate();
          searchField.focus = true;
        }
      }*/
  }

  // This is where the actual business happens.
  Milou.ResultsView {
    id: listView
    //in case is expanded
    //clip: true
    visible: true
    //height: 100
    //width: 100
    height: parent.height
    //width: parent.width
    width: dashboard.screenWidth/2
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: searchField.bottom
    //anchors.left: parent.left
    anchors.verticalCenter: parent.verticalCenter

    onActivated: {
      searchField.text = "";
      dashboard.toggleBoth();
      //searchField.forceActiveFocus();
    }
  }

  Component.onCompleted: {
    //searchField.setFocus();
  }

  Keys.onEscapePressed: {
    //currentDesktopGridThumbnailContainer.state = 'showDesktop';
    searchField.text = "";
    //searchField.forceActiveFocus();
    //currentDesktopGrid.visible = !currentDesktopGrid.visible;
  }

  Keys.forwardTo: listView

  /*Keys.onReturnPressed: {
    searchField.text = '';
  }*/


}
