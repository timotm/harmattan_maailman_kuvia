/*
    This file is part of Maailmankuvia.

    Maailmankuvia is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Maailmankuvia is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Maailmankuvia.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 1.0
import com.nokia.meego 1.0

/* element in the JSON array looks like this
    {"id":"346",
    "pic_url":"maailmankuvat_1316505633.jpg",
    "pic_credit":"Alexander F Yaun",
    "is_hs_photo":"0",
    "pic_text":"Kiinan muuri ilta-auringossa Luanpingissa Pohjois-Kiinassa.",
    "date":"2011-09-20",
    "latitude":"40.943",
    "longitude":"117.341",
    "location":"Luanping, Kiina",
    "pic_agency":"AP",
    "published":"1",
    "thumbnail_converted":"1"}*/

Page {
    orientationLock: PageOrientation.LockLandscape
    property bool showTextBox: true
    property bool parsing: true

    function addToImageModel(value, index, array) {
        var picurl = "http://hs-kuvat.hs.fi//pictures/" + value['pic_url']
        imageModel.append( { url : picurl, caption : value['location'] + " <i>Kuva: " + value['pic_credit'] + "</i>" + "<p>" + value['pic_text'] } )
    }

    Rectangle {
        anchors.fill: parent


        VisualDataModel {
            id: topModel

            model: ListModel{
                id:imageModel
            }

            delegate: Rectangle {
                id: delId
                width: listView.width;
                height: listView.height;

                SimpleProgressBar {
                    minimum: 0.0
                    maximum: 100.0
                    value: image.progress * 100.0
                    visible: image.status == Image.Loading
                    anchors.centerIn: parent
                }
                Image {
                    id: image
                    source: url
                    fillMode: Image.PreserveAspectFit
                    sourceSize.width: delId.width
                    sourceSize.height: delId.height
                }

                Rectangle {
                    visible: image.status == platformWindow.viewMode != WindowState.Fullsize || (image.status == Image.Ready && showTextBox)
                    id: textBox

                    NokiaText {
                        id: textBoxText
                        width: delId.width - 60;
                        x: 30
                        y: 450 - textBoxText.height
                        z: textBoxBox.z + 1
                        text: platformWindow.viewMode == WindowState.Fullsize ? caption : " HS.fi maailman kuvia"
                        font.pointSize: platformWindow.viewMode == WindowState.Fullsize ? 22 : 52
                        color: "#ffffff"
                        wrapMode: Text.Wrap
                        opacity: 1
                    }

                    Rectangle {
                        id: textBoxBox
                        height: textBoxText.height + 10
                        width: delId.width - 40
                        x: 20
                        y: textBoxText.y
                        opacity: 0.5
                        color: "#000000"
                    }
                }
            }
        }

        ListView {
            id: listView
            visible: ! parsing
            anchors.fill: parent
            model: topModel
            orientation: ListView.Horizontal
            snapMode: ListView.SnapOneItem
            cacheBuffer: width * 3
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    showTextBox = !showTextBox
                }
            }
        }

        Rectangle {
            x: 0
            y: 0
            width: parent.width
            height: parent.height
            visible: parsing

            NokiaText {
                anchors.centerIn: parent
                id: errorText
            }

            Rectangle {
                width: 300
                height: 80
                anchors.top: errorText.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.topMargin: 20
                id: retryButton
                visible: false
                color: "#4591ff"
                radius: 8

                NokiaText {
                    anchors.centerIn: parent
                    text: "Yritä uudelleen"
                    color: "#ffffff"
                    style: Text.Sunken

                    MouseArea {
                        id: retryButtonMouseArea
                        anchors.fill: parent
                        onClicked: {
                            reload()
                        }
                    }
                }
            }

            states: State {
                name: "pressed"; when: retryButtonMouseArea.pressed == true
                PropertyChanges { target: retryButton; opacity: .4 }
            }
        }

        Timer {
            id: networkTimer
            interval: 15000
            running: true
            repeat: false

            onTriggered: {
                errorText.text = "Ei saatu yhteyttä palvelimeen"
                retryButton.visible = true
            }
        }


        Component.onCompleted: {
            reload()
        }

        function reload() {
            retryButton.visible = false
            errorText.text = "Ladataan.."
            parsing = true

            var doc = new XMLHttpRequest();

            doc.onreadystatechange = function() {
                if (doc.readyState == XMLHttpRequest.DONE) {
                    if (doc.status != 200) {
                        errorText.text = "Ei saatu yhteyttä palvelimeen"
                        retryButton.visible = true
                    }
                    else {
                        var object = JSON.parse(doc.responseText)
                        parsing = false
                        imageModel.clear()
                        object.forEach(addToImageModel)
                    }
                    networkTimer.running = false
                }
            }

            doc.open("GET", "http://hs-kuvat.hs.fi/hallinta/api.php")
            doc.send()
        }

        Connections {
             target: Qt.application
             onActiveChanged: {
                if (Qt.application.active) {
                    listView.cacheBuffer = listView.width * 4
                }
                else {
                    listView.cacheBuffer = 0
                }
            }
         }
    }
}
