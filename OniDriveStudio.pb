Global Img_MainWindow_0

Enumeration FormWindow
   #MainWindow
EndEnumeration

Enumeration FormGadget
   #Panel_Main
   #Button_ReadParameters
   #Button_WriteParameters
   #Image_Logo
   #Tree_Parameters
   #ListIcon_Parameters
   #Splitter_Parameter
   #ComboBox_Parameter
EndEnumeration

Enumeration FormMenu
   #MenuItem_FileNew
   #MenuItem_FileOpen
   #MenuItem_FileSave
   #MenuItem_FileSaveAs
   #MenuItem_FileExit
   #MenuItem_Help
   #MenuItem_About
EndEnumeration

UsePNGImageDecoder()

Img_MainWindow_0 = LoadImage(#PB_Any,"D:\Работа\ONI Drive Studio\Project\Logo_169x35.png")

Structure Combo_Param
   Item_ID.l
   Number.u
   Name$
EndStructure

Structure Parameter
   Parameter_Group$
   Name$
   Combo_Num.u        ; если=0, то комбо нет
   Item_ID.l
   Read_Value.u
   Set_Value.u
   Default_Value$
   Min_Value$
   Max_Value$
   Digit.u
   Modbus_Addr.u
   Modbus_Addr_EE.u
   Write_Mode.u        ;0=только для чтения, 1=только при остановке, 2=всегда
EndStructure

Structure Parameter_Group
   Main_Group$
   Name$
   TreeID.l
EndStructure

Structure Main_Group
   Name$
   TreeID.l
EndStructure

Structure ListID_ItemID
   ListID.l
   ItemID.l
EndStructure

Global NewMap Main_Group.Main_Group()
Global NewMap Parameter_Group.Parameter_Group()
Global NewMap Parameter.Parameter()
Global NewList Combo_Param.Combo_Param()
Global NewMap ListID_ItemID.l()

IncludeFile "Map_A310.pb"

#LVM_SUBITEMHITTEST = #LVM_FIRST + 57 
#LVM_GETSUBITEMRECT = #LVM_FIRST + 56 

Global oldProc 
Global currentItem, currentSubItem, ListItemID

Procedure MainWindowCallBack(hwnd, msg, wparam, lparam)
   result = #PB_ProcessPureBasicEvents
   Select msg
      Case #WM_DRAWITEM
         ;Debug "#WM_DRAWITEM"
         *lpdis.DRAWITEMSTRUCT = lparam
         Dim itemrect.RECT(6)
         For i = 1 To 6
            RtlZeroMemory_(@itemrect(i),SizeOf(RECT))
            itemrect(i)\top = i
            SendMessage_(*lpdis\hwndItem, #LVM_GETSUBITEMRECT, *lpdis\itemid, @itemrect(i))
            text$ = GetGadgetItemText(GetDlgCtrlID_(*lpdis\hwndItem), *lpdis\itemid, i)
            SelectObject_(*lpdis\hDC, GetStockObject_(#NULL_PEN))
            WhiteBrush = CreateSolidBrush_(#White)
            SelectObject_(*lpdis\hDC, WhiteBrush)
            Rectangle_(*lpdis\hDC, itemrect(i)\left, itemrect(i)\top, itemrect(i)\right, itemrect(i)\bottom) 
            TextOut_(*lpdis\hDC, itemrect(i)\left+4, itemrect(i)\top+4, text$, Len(text$)) 
            DeleteObject_(WhiteBrush) 
         Next 
      Case #WM_MEASUREITEM 
         Debug "#WM_MEASUREITEM"
         *lpmis.MEASUREITEMSTRUCT = lparam 
         *lpmis\itemheight = 21 
      Case #WM_SIZE
         Debug "#WM_SIZE"
         ResizeGadget(#Panel_Main, #PB_Ignore, #PB_Ignore, WindowWidth(#MainWindow)-10, WindowHeight(#MainWindow)-55)
         ResizeGadget(#Button_ReadParameters, #PB_Ignore, WindowHeight(#MainWindow)-120, #PB_Ignore, #PB_Ignore)
         ResizeGadget(#Button_WriteParameters, #PB_Ignore, WindowHeight(#MainWindow)-120, #PB_Ignore, #PB_Ignore)
         ResizeGadget(#Image_Logo, WindowWidth(#MainWindow)-200, WindowHeight(#MainWindow)-125, #PB_Ignore, #PB_Ignore)
         ResizeGadget(#Splitter_Parameter, #PB_Ignore, #PB_Ignore, WindowWidth(#MainWindow)-35, WindowHeight(#MainWindow)-140)
   EndSelect 
   ProcedureReturn result 
EndProcedure 

Procedure ResizeCombo(hwnd)
   RtlZeroMemory_(@itemrect.RECT, SizeOf(RECT)) 
   itemrect\top = currentSubItem 
   SendMessage_(hwnd, #LVM_GETSUBITEMRECT, currentItem, @itemrect)
   ;ForEach ListID_ItemID()
   ResizeGadget(ListID_ItemID(Str(currentItem)), itemrect\left, itemrect\top, itemrect\right-itemrect\left, #PB_Ignore)
   InvalidateRect_(GadgetID(ListID_ItemID(Str(currentItem))), 0, 1)
   ;Next
EndProcedure

Procedure SubClass_LV(hwnd, msg, wparam, lparam) 
   result = CallWindowProc_(oldproc, hwnd, msg, wparam, lparam) 
   If msg=#WM_LBUTTONDOWN ;Or msg = #WM_RBUTTONDOWN
      GetCursorPos_(@cp.POINT) 
      MapWindowPoints_(0,hwnd,@cp,1) 
      hitInfo.LVHITTESTINFO 
      hitInfo\pt\x = cp\x 
      hitInfo\pt\y = cp\y 
      Debug "cp\x = "+cp\x+"   cp\y = "+cp\y
      SendMessage_(hwnd, #LVM_SUBITEMHITTEST, 0, @hitInfo) 
      Debug "hitInfo\iSubItem: "+hitInfo\iSubItem+" hitInfo\iItem: "+hitInfo\iItem
      If hitInfo\iSubItem > 0 And hitInfo\iItem >= 0 
         Debug "currentItem: "+currentItem+"  currentSubItem: "+currentSubItem
         If currentSubItem = 3 And currentItem >= 0
            HideGadget(ListID_ItemID(Str(currentItem)), 1)
         EndIf
         currentItem    = hitInfo\iItem 
         currentSubItem = hitInfo\iSubItem 
         Debug "currentItem: "+currentItem+"  currentSubItem: "+currentSubItem
         RtlZeroMemory_(@itemrect.RECT, SizeOf(RECT)) 
         itemrect\top = hitInfo\iSubItem 
         SendMessage_(hwnd, #LVM_GETSUBITEMRECT, hitInfo\iItem, @itemrect) 
         If hitInfo\iSubItem = 3 
            Debug ListID_ItemID(Str(currentItem))
            ResizeGadget(ListID_ItemID(Str(currentItem)), itemrect\left, itemrect\top, itemrect\right-itemrect\left, itemrect\bottom-itemrect\top) 
            ;SetGadgetState(ListID_ItemID(Str(currentItem)), 0) 
            HideGadget(ListID_ItemID(Str(currentItem)),0) 
            ;Else 
            ;   ForEach ListID_ItemID()
            ;      If IsGadget(ListID_ItemID())<>0
            ;         Debug "IsGadget: "+IsGadget(ListID_ItemID())
            ;         HideGadget(ListID_ItemID(), 1)
            ;      EndIf
            ;   Next
         EndIf 
         ;Else 
         ;   ForEach ListID_ItemID()
         ;      If IsGadget(ListID_ItemID())<>0
         ;         Debug "IsGadget: "+IsGadget(ListID_ItemID())
         ;         HideGadget(ListID_ItemID(), 1)
         ;      EndIf
         ;   Next
      EndIf 
   ElseIf msg=#WM_HSCROLL Or msg=#WM_VSCROLL 
      ResizeCombo(hwnd)
      HideGadget(ListID_ItemID(Str(currentItem)),1)
      Debug "#WM_SCROLL"
   ElseIf msg=#WM_NOTIFY 
      Debug "#WM_NOTIFY"
      *nmHEADER.HD_NOTIFY = lParam 
      Select *nmHEADER\hdr\code 
         Case #HDN_ITEMCHANGING
            Debug "#HDN_ITEMCHANGING"
            ResizeCombo(hwnd)
      EndSelect
   ElseIf msg=#WM_MOUSEWHEEL
      ResizeCombo(hwnd)
      HideGadget(ListID_ItemID(Str(currentItem)),1)
      Debug "#WM_MOUSEWHEEL"
   EndIf 
   ProcedureReturn result 
EndProcedure

Procedure.s WordToStr(value.u, digit)
   Protected a.u, b.u
   b=value%Int(Pow(10,digit))
   a=(value-b)/Pow(10,digit)
   ProcedureReturn Str(a)+"."+Str(b)
EndProcedure

Procedure LoadParameters(Parameter_Group$)
   ForEach Parameter()
      If Parameter()\Parameter_Group$=Parameter_Group$
         Code$=MapKey(Parameter())
         ;Debug MapKey(Parameter())
         Item_ID=Parameter()\Item_ID
         Name$=Parameter()\Name$
         Min_Value$=Parameter()\Min_Value$
         Max_Value$=Parameter()\Max_Value$
         Modbus_Addr=Parameter()\Modbus_Addr_EE
         Default_Value$=Parameter()\Default_Value$
         If Parameter()\Combo_Num<>0
            ;Debug Parameter()\Item_ID
            AddGadgetItem(#ListIcon_Parameters, -1, Chr(10) + Code$ + Chr(10) + Name$ + Chr(10) + "" + Chr(10) + Min_Value$+" ... "+Max_Value$ + Chr(10) + Default_Value$ + Chr(10) + Str(Modbus_Addr))
            ListID_ItemID(Str(ListItemID))=Item_ID
            ComboBoxGadget(Item_ID, 0, 0, 0, 0, #PB_Window_Invisible)
            SetParent_(GadgetID(Item_ID), GadgetID(#ListIcon_Parameters))
            ForEach Combo_Param()
               If Combo_Param()\Item_ID=Item_ID
                  AddGadgetItem(Item_ID, -1, Str(Combo_Param()\Number)+": "+Combo_Param()\Name$)
               EndIf
            Next
            SetGadgetState(Item_ID, Val(Default_Value$)-Val(Min_Value$))
            SetGadgetItemText(#ListIcon_Parameters, ListItemID, GetGadgetText(Item_ID), 3)
            HideGadget(Item_ID, 1)
         Else
            AddGadgetItem(#ListIcon_Parameters, -1, Chr(10) + Code$ + Chr(10) + Name$ + Chr(10) + "" + Chr(10) + Min_Value$+" ... "+Max_Value$ + Chr(10) + Default_Value$ + Chr(10) + Str(Modbus_Addr))
            ListID_ItemID(Str(ListItemID))=Item_ID
            StringGadget(Item_ID, 0, 0, 0, 0, "")
            SetParent_(GadgetID(Item_ID), GadgetID(#ListIcon_Parameters))
            SetGadgetText(Item_ID, Default_Value$)
            SetGadgetItemText(#ListIcon_Parameters, ListItemID, GetGadgetText(Item_ID), 3)
            HideGadget(Item_ID, 1)
         EndIf
         ListItemID=ListItemID+1
      EndIf
   Next
EndProcedure

;=============================================================================================== Main Section

Load_A310()

;Procedure OpenMainWindow(x = 0, y = 0, width = 960, height = 640)
;OpenWindow(#MainWindow, 0, 0, 960, 640, "ONI Drive Studio", #PB_Window_SystemMenu | #PB_Window_MinimizeGadget | #PB_Window_TitleBar)
OpenWindow(#MainWindow, 0, 0, 960, 640, "ONI Drive Studio", $CF0001)
CreateStatusBar(0, WindowID(#MainWindow))
AddStatusBarField(120)
StatusBarText(0, 0, "Текущая модель ПЧ")
AddStatusBarField(50)
StatusBarText(0, 1, "A310")
CreateMenu(0, WindowID(#MainWindow))
MenuTitle("Файл")
MenuItem(#MenuItem_FileNew, "Новый")
MenuItem(#MenuItem_FileOpen, "Открыть")
MenuItem(#MenuItem_FileSave, "Сохранить")
MenuItem(#MenuItem_FileSaveAs, "Сохранить как")
MenuBar()
MenuItem(#MenuItem_FileExit, "Выход")
MenuTitle("Подключение")
MenuTitle("Помощь")
MenuItem(#MenuItem_Help, "Справка")
MenuItem(#MenuItem_About, "О программе")
PanelGadget(#Panel_Main, 5, 5, 950, 585)
AddGadgetItem(#Panel_Main, -1, "Параметры")
ButtonGadget(#Button_ReadParameters, 15, 520, 120, 30, "Прочитать из ПЧ")
ButtonGadget(#Button_WriteParameters, 150, 520, 120, 30, "Записать в ПЧ")
ImageGadget(#Image_Logo, 760, 515, 169, 35, ImageID(Img_MainWindow_0))
TreeGadget(#Tree_Parameters, 10, 8, 232, 500, #PB_Tree_AlwaysShowSelection)

ListIconGadget(#ListIcon_Parameters, 251, 8, 684, 500, "", 0, #PB_ListIcon_GridLines | #PB_ListIcon_FullRowSelect | #LVS_OWNERDRAWFIXED)
oldproc = SetWindowLong_(GadgetID(#ListIcon_Parameters), #GWL_WNDPROC, @SubClass_LV())
AddGadgetColumn(#ListIcon_Parameters, 1, "Код", 50)
AddGadgetColumn(#ListIcon_Parameters, 2, "Название", 220)
AddGadgetColumn(#ListIcon_Parameters, 3, "Значение", 200)
AddGadgetColumn(#ListIcon_Parameters, 4, "Диапазон", 100)
AddGadgetColumn(#ListIcon_Parameters, 5, "По умолчанию", 80)
AddGadgetColumn(#ListIcon_Parameters, 6, "Modbus адр.", 80)
SplitterGadget(#Splitter_Parameter, 10, 8, 925, 500, #Tree_Parameters, #ListIcon_Parameters, #PB_Splitter_Vertical)
SetGadgetState(#Splitter_Parameter, 235)

AddGadgetItem(#Tree_Parameters, -1, "Все параметры", 0, 0)
TreeItemID=0
ListItemID=0
SetGadgetItemState(#Tree_Parameters, 0, #PB_Tree_Expanded)
ForEach Main_Group()
   AddGadgetItem(#Tree_Parameters, -1, "Группа "+MapKey(Main_Group())+" - "+Main_Group()\Name$, 0, 1)
   TreeItemID=TreeItemID+1
   Main_Group()\TreeID=TreeItemID
   ;Debug MapKey(Main_Group())
   ForEach Parameter_Group()
      If Parameter_Group()\Main_Group$=MapKey(Main_Group())
         AddGadgetItem(#Tree_Parameters, -1, MapKey(Parameter_Group())+" - "+Parameter_Group()\Name$, 0, 2)
         TreeItemID=TreeItemID+1
         Parameter_Group()\TreeID=TreeItemID
         
         ;Debug MapKey(Parameter_Group())+" - "+Parameter_Group()\Name$
      EndIf
   Next
Next
For i=0 To TreeItemID
   SetGadgetItemState(#Tree_Parameters, i, #PB_Tree_Expanded)
Next   
SetGadgetState(#Tree_Parameters, 0)
SetActiveGadget(#Tree_Parameters)
AddGadgetItem(#Panel_Main, -1, "Оперативное управление")

ForEach Main_Group()
   ForEach Parameter_Group()
      If Parameter_Group()\Main_Group$=MapKey(Main_Group())
         LoadParameters(MapKey(Parameter_Group()))
      EndIf
   Next
Next
;EndProcedure

;Procedure MainWindow_Events(event)
;   Select event
;      Case #PB_Event_CloseWindow
;         ProcedureReturn #False
;         
;      Case #PB_Event_Menu
;         Select EventMenu()
;            Case #MenuItem_FileNew
;            Case #MenuItem_FileOpen
;            Case #MenuItem_FileSave
;            Case #MenuItem_FileSaveAs
;            Case #MenuItem_FileExit
;            Case #MenuItem_Help
;            Case #MenuItem_About
;         EndSelect
;         
;      Case #PB_Event_Gadget
;         Select EventGadget()
;            Case #ListIcon_Parameters
;               If EventType()=#PB_EventType_Change
;                  SetGadgetItemText(#ListIcon_Parameters, currentitem, GetGadgetText(1), currentsubitem)
;                  Debug currentitem
;                  Debug currentsubitem
;                  HideGadget(1,1)
;               EndIf
;         EndSelect
;   EndSelect
;   ProcedureReturn #True
;EndProcedure

;Load_A310()
;OpenMainWindow()

SetWindowCallback(@MainWindowCallBack(), #MainWindow)
Repeat 
   EventID = WaitWindowEvent()
   Select EventID 
      Case #PB_Event_Menu
         Select EventMenu()
            Case #MenuItem_FileNew
               Load_A310()
               ClearGadgetItems(#ListIcon_Parameters)
               ListItemID=0
               ;Debug "Грузим все"
               ForEach Main_Group()
                  ForEach Parameter_Group()
                     If Parameter_Group()\Main_Group$=MapKey(Main_Group())
                        LoadParameters(MapKey(Parameter_Group()))
                     EndIf
                  Next
               Next
            Case #MenuItem_FileOpen
            Case #MenuItem_FileSave
            Case #MenuItem_FileSaveAs
            Case #MenuItem_FileExit
            Case #MenuItem_Help
            Case #MenuItem_About
         EndSelect
      Case #PB_Event_Gadget
         Select EventGadget()
            Case #Tree_Parameters
               If EventType()=#PB_EventType_Change
                  ClearGadgetItems(#ListIcon_Parameters)
                  ListItemID=0
                  If GetGadgetState(#Tree_Parameters)=0
                     ;Debug "Грузим все"
                     ForEach Main_Group()
                        ForEach Parameter_Group()
                           If Parameter_Group()\Main_Group$=MapKey(Main_Group())
                              LoadParameters(MapKey(Parameter_Group()))
                           EndIf
                        Next
                     Next
                  Else
                     ForEach Main_Group()
                        If Main_Group()\TreeID=GetGadgetState(#Tree_Parameters)
                           ForEach Parameter_Group()
                              If Parameter_Group()\Main_Group$= MapKey(Main_Group())
                                 ;Debug "Грузим "+ MapKey(Parameter_Group())
                                 LoadParameters(MapKey(Parameter_Group()))
                              EndIf
                           Next
                           Break
                        EndIf
                     Next
                     ForEach Parameter_Group()
                        If Parameter_Group()\TreeID=GetGadgetState(#Tree_Parameters)
                           ;Debug "Грузим "+ MapKey(Parameter_Group())
                           LoadParameters(MapKey(Parameter_Group()))
                           Break
                        EndIf
                     Next
                  EndIf
               EndIf
            Case ListID_ItemID(Str(currentItem))
               If EventType()=#PB_EventType_ReturnKey
                  Debug  "#PB_EventType_ReturnKey"
               EndIf
               If EventType()=#PB_EventType_Change 
                  Debug "#PB_EventType_Change: "+ListID_ItemID(Str(currentItem))
                  ForEach Parameter()
                     If Parameter()\Item_ID = ListID_ItemID(Str(currentItem))
                        If Parameter()\Combo_Num > 0
                           SetGadgetItemText(#ListIcon_Parameters, currentItem, GetGadgetText(ListID_ItemID(Str(currentItem))), currentSubItem)
                           SetGadgetState(Item_ID, Val(Default_Value$)-Val(Min_Value$))
                           Parameter()\Set_Value = GetGadgetState(ListID_ItemID(Str(currentItem)))+Val(Parameter()\Min_Value$)
                           Debug Parameter()\Name$+" = "+Parameter()\Set_Value
                           ;Debug "currentitem = "+currentItem
                           ;Debug "currentsubitem = "+currentSubItem
                           ;Debug "ListID_ItemID(Str(currentItem)) = "+ListID_ItemID(Str(currentItem))
                           ;Debug "GetGadgetText: "+GetGadgetText(ListID_ItemID(Str(currentItem)))
                           HideGadget(ListID_ItemID(Str(currentItem)), 1)
                        Else 
                           Debug GetGadgetText(ListID_ItemID(Str(currentItem)))
                        EndIf
                        Break
                     EndIf
                  Next
               EndIf
         EndSelect
   EndSelect
Until EventID = #PB_Event_CloseWindow
End
