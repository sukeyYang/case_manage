<%--
  Created by IntelliJ IDEA.
  User: gaoyang
  Date: 16/3/6
  Time: 下午12:43
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="head.jsp"%>
<html>
<head>
    <title>患者管理</title>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
</head>
<script type="text/javascript">
    var gridManager = null;
    var saveForm = null;
    var saveWindow = null;
    var typeData = null;
    var icon = '${ctx}/ligerUI/skins/icons/pager.gif';

    $(function() {
        $("#searchbtn").ligerButton({
            click : function() {
                search();
            }
        });

        setGrid();
        //initSaveForm('text');

        $("#pageloading").hide();
    });
    function initSaveForm(inputType){
        saveForm = $("#saveForm").ligerForm({
            inputWidth : 170,
            labelWidth : 100,
            space : 45,
            validate : true,
            fields : [
                {name : "patientid", type : "hidden"},
                {display : "登录名", name : "username", type : "text", group : "编辑", groupicon : icon,				validate : {
                    required : true,
                    maxlength : 20
                }},
                {display : "姓名", name : "name", type : "text",newline : false,
                    validate : {
                        required : true,
                        maxlength : 20
                    }
                },{	display : "性别",
                    name : "sex",
                    newline : true,
                    type : inputType,
                    type : "html",
                    htmlattr : "checked",
                    html : '<input id="sta" type="radio" name="sta" checked="checked" value="1"/>' +
                    '<label for="CheckBoxList1_0">男</label>&nbsp;<input id="sta" type="radio" name="sta" value="2"/>' +
                    '<label for="CheckBoxList1_0">女</label>&nbsp;'
                },
                {	display : "手机号",
                    name : "phone",
                    newline : true,
                    type : inputType,
                    validate : {
                        required : true,
                        maxlength : 11
                    }
                }, {
                    display : "地址",
                    name : "address",
                    newline : false,
                    type : "text",
                    validate : {
                        required : true,
                        maxlength : 500
                    }
                }, {
                    display : "邮件",
                    name : "email",
                    newline : false,
                    type : "text",
                    validate : {
                        required : true,
                        maxlength : 500
                    }
                }]
        });
    }
    function setGrid(){
        //表格
        gridManager = $("#maingrid").ligerGrid({
            columns : [
                {
                    display: '操作',
                    isSort: false,
                    isExport: false,
                    width: 50,
                    align : 'right',
                    render: function (rowdata, rowindex, value)
                    {
                        return "<img title='修改' onclick='editColumn("+JSON.stringify(rowdata)+");' style='margin-top:5px;cursor:pointer;' src='${ctx}/ligerUI/skins/icons/editform.png'/>&nbsp;&nbsp;&nbsp;";
                    }
                },
                {
                    display : '姓名',
                    name : 'name',
                    align : 'center',
                    width : 100,
                    minWidth : 30
                },{
                    display : '登录名',
                    name : 'username',
                    align : 'left',
                    width : 200,
                    minWidth : 60
                }, {
                    display : '手机号',
                    name : 'phone',
                    width : 300,
                    minWidth : 30,
                    align : 'left'
                }, {
                    display : '性别',
                    name : 'sex',
                    minWidth : 100,
                    align : 'left',
                    width : 300
                },
                {
                    display : '地址',
                    name : 'address',
                    minWidth : 100,
                    align : 'left',
                    width : 300
                },
                {
                    display : '邮箱',
                    name : 'email',
                    minWidth : 100,
                    align : 'left',
                    width : 300
                }
            ],
            width : '99%',
            height : '100%',
            heightDiff : -10,
            pageSize : 15,
            url : "${ctx}/patient/searchlist",
            rownumbers : true,
            checkbox : true,
            selectRowButtonOnly : true,
            isScroll : true,
            toolbar : {
                items : [ {
                    id : 'add',
                    text : '增加',
                    click : itemclick,
                    img : '${ctx}/ligerUI/skins/icons/addpage.png'
                }, {
                    id : 'delete',
                    text : '删除',
                    click : itemclick,
                    img : '${ctx}/ligerUI/skins/icons/busy.gif'
                }]
            }
        });
    }

    function editColumn(data){
        var inputType = 'text';
        if(data.name != undefined && data.name != null && data.name.indexOf('PASSWORD') >= 0){
            inputType = 'password';
        }

        initSaveForm(inputType);
        showWindow();

        saveForm.setData({
            settingid: data.id,
            name: data.name,
            module : data.module,
            value : data.value,
            brief : data.brief,
        });

    }

    function search(){
        var parms = $("#queryForm").serializeJson();
        gridManager.set("parms", parms);
        gridManager.loadData();
    }

    function renderDescription(rowdata, index, value) {
        if(value != null) {
            return "<div title='" + value + "'>" + value + "<div>";
        }
    }

    function showWindow(){
        if (saveWindow == null) {
            saveWindow = $.ligerDialog.open({
                target : $("#addWindow"),
                width : 400,
                height : 'auto',
                isResize : true
            });
        }
        $("#saveForm")[0].reset();
        saveForm.hideAllFieldError();
        //$("#saveForm").resetStyle();
        saveWindow.show();
    }

    function itemclick(item) {
        if (item.id) {
            switch (item.id) {
                case "add":
                    initSaveForm('text');
                    showWindow();
                    saveForm.setData({
                        settingid : null
                    });
                    return;
                case "delete":
                    var data = gridManager.getCheckedRows();
                    if (data.length == 0) {
                        $.ligerDialog.waitting('请选择行');
                        setTimeout(function() {
                            $.ligerDialog.closeWaitting();
                        }, 500);
                    } else {
                        $.ligerDialog.confirm('确认要删除?', function(yes) {
                            if (yes) {
                                removeData(data);
                            }
                        });
                    }
                    return;
                case "export":
                    exportExcel(gridManager, $("#queryForm"), '${ctx}');
                    return ;
            }
        }
    }

    function closeWindow() {
        saveWindow.hide();
    }

    function removeData(data) {
        $.ajax({
            type : "POST",
            url : "${ctx}/common/removeSetting",
            data : JSON.stringify(data),
            contentType : "application/json; charset=utf-8",
            dataType : "text",
            success : function(result) {
                if (result == 'success') {
                    search();
                    $.ligerDialog.waitting('删除成功');
                    setTimeout(function() {
                        $.ligerDialog.closeWaitting();
                    }, 500);
                } else {
                    $.ligerDialog.warn(result);
                }
            }
        });
    }

    function save() {
        if (saveForm.valid()) {
            $("#pageloading").show();
            var params = saveForm.getData();
            $.ajax({
                type : "POST",
                url : "savepatient",
                data : JSON.stringify(params),
                contentType : "application/json;charset=utf-8",
                dataType : "text",
                success : function(result) {
                    if (result == 'success') {
                        search();
                        saveWindow.hide();
                        $.ligerDialog.waitting('操作成功');
                        setTimeout(function() {
                            $.ligerDialog.closeWaitting();
                        }, 500);
                    } else {
                        $.ligerDialog.warn(result);
                    }
                    $("#pageloading").hide();
                }
            });
        }
    }
</script>
</head>
<body style="padding: 5px;">
<div class="l-loading" style="display:block" id="pageloading"></div>
<form id="queryForm">
    <input type="hidden" id="service" name="service"
           value="SettingServiceImpl" />
    <div class="l-panel-search">
        <div class="l-panel-search-item">Module</div>
        <div class="l-panel-search-item">
            <input type="text" id="queryModule" name="queryModule"  class="liger-textbox" />
        </div>
        <div class="l-panel-search-item">Name</div>
        <div class="l-panel-search-item">
            <input type="text" id="queryName" name="queryName"  class="liger-textbox" />
        </div>
        <div class="l-panel-search-item">
            <input type="button" id="searchbtn" value="查询" />
        </div>
    </div>
</form>
<!-- 表格 -->
<div id="maingrid" style="margin:0; padding:0"></div>
<div style="display:none;"></div>
<div id="addWindow" style="width:99%; margin:3px; display:none;">
    <div class="l-dialog-body" style="width: 100%;">
        <form id="saveForm"></form>
        <div class="l-dialog-buttons">
            <div class="l-dialog-buttons-inner">
                <div class="l-dialog-btn">
                    <div class="l-dialog-btn-l"></div>
                    <div class="l-dialog-btn-r"></div>
                    <div class="l-dialog-btn-inner" onclick="closeWindow();">取消</div>
                </div>
                <div class="l-dialog-btn">
                    <div class="l-dialog-btn-l"></div>
                    <div class="l-dialog-btn-r"></div>
                    <div class="l-dialog-btn-inner" onclick="save();">确定</div>
                </div>
                <div class="l-clear"></div>
            </div>
        </div>
    </div>
</div>
</body>
</html>