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

import QtQuick 1.1
import com.nokia.meego 1.0

PageStackWindow {
    id: rootWindow
    initialPage: MainPage { }
    showStatusBar: false

     // These tools are shared by most sub-pages by assigning the
     // id to a page's tools property
     ToolBarLayout {
         id: commonTools
         visible: false
         ToolIcon {
             iconId: "toolbar-back";
             onClicked: { myMenu.close(); pageStack.pop(); }
         }
         ToolIcon {
             iconId: "toolbar-view-menu";
             onClicked: (myMenu.status == DialogStatus.Closed) ? myMenu.open() : myMenu.close()
         }
     }
}
