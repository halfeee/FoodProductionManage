<%@ page import="cn.qxt.pojo.PlanStaff" %><%--
  Created by IntelliJ IDEA.
  User: 10703
  Date: 2019/11/2
  Time: 14:50
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html lang="zh-cn">
<head>
    <meta charset="UTF-8">
    <meta content="IE=edge" http-equiv="X-UA-Compatible">
    <meta content="initial-scale=1.0, maximum-scale=1.0, user-scalable=no, width=device-width" name="viewport">
    <link rel="shortcut icon" href="${pageContext.request.contextPath}/images/labellogo.jpg" type="image/x-icon">
    <meta name="theme-color" content="#4285f4">
    <title>员工界面</title>

    <link href="${pageContext.request.contextPath}/theme/css/base.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/theme/css/project.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css?family=Material+Icons" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/theme/css/user.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/theme/css/style.css">



    <script type="text/javascript" src="${pageContext.request.contextPath}/theme/js/jQuery-2.1.4.min.js"></script>
    <script type="text/javascript" src="${pageContext.request.contextPath}/theme/js/jquery.tablesorter.js"></script>

    <script src="https://cdn.jsdelivr.net/gh/davidshimjs/qrcodejs@gh-pages/qrcode.min.js" type="text/javascript"></script>
    <script src="${pageContext.request.contextPath}/theme/js/base.min.js" type="text/javascript"></script>
    <script src="${pageContext.request.contextPath}/theme/js/project.min.js" type="4text/javascript"></script>

    <script>
        var requirementIdList = [[]];
        //根据所选要求制定生产计划
        function drawUpPlan() {
            var product_idList = [];
            var quantityList = [];
            var nameList = [];
            //把生产需求的创建时间放进去，根据此找到需求，改变状态
            var check = $("table input[type=checkbox]:checked");//在table中找input下类型为checkbox属性为选中状态的数据
            //遍历被选中的数据
            check.each(function () {
                var row = $(this).parent("th").parent("tr");//获取选中行

                var product_id = row.find("[name='product_id']").html();//获取name='product_id'的值
                var quantity = row.find("[name='quantity']").html();
                var name = row.find("[name='name']").html();
                var id = row.find("[name='id']").html();
                var create_time = row.find("[name='create_time']").html();

                if (product_id !== undefined)
                {
                    product_idList.push(product_id);
                    //二维数组
                    if(requirementIdList[product_id] === undefined)
                        requirementIdList[product_id]=[];
                    requirementIdList[product_id].push(id);

                    nameList[product_id] = name;
                    if (quantityList[product_id] === undefined)
                        quantityList[product_id] = Number(quantity);
                    else
                        //记得把quantity转换为数字
                        quantityList[product_id] += Number(quantity);

                }
            });
            var requirementTable = document.getElementById("requirementTable");
            var planHTML=[];

            $.ajax({
                type: "POST",
                url: "${pageContext.request.contextPath}/admin/staff/plan/staff/classify",
                dataType: "json",
                async:false,
                traditional:true,
                data: {
                    product_idList : product_idList
                },
                success: function(data) {
                    var quantityMap = data.quantityMap;
                    //alert(quantityMap);
                    for(var key in quantityMap){
                        // console.log(key + "==" + quantityMap[key]);
                        planHTML.push('<div name="aplan">\n'+
                            '<p id="id_label">产品ID：<span id="id">'+  key +'</span></p>\n' +
                            '<p id="name_label">产品名称：<span id="name">'+  nameList[key] +'</span></p>\n' +
                            '<p id="repertory_label">产品库存：<span id="repertory">'+  quantityMap[key] +'</span></p>\n' +
                            '<p id="requirement_label">需求量：<input id="requirement" type="number" value="'+ quantityList[key] +'"></p>'
                            );
                    }
                    //查找可用的车间
                    $.ajax({
                        type: "POST",
                        url: "${pageContext.request.contextPath}/admin/staff/plan/staff/listWorkshop",
                        dataType: "json",
                        async:false,
                        traditional:true,
                        data: {
                        },
                        success: function(data) {
                            let select = '';
                            var workshopList = eval(data.workshopList);
                            for (let i=0; i<workshopList.length; i++)
                            {
                                let workshop = workshopList[i];
                                select += '<option value="'+ workshop.id +'">'+workshop.name+'</option>';
                            }
                            planHTML.push('<div>\n'+
                                '<p>请选择生产车间：' +
                                '<select id="workshop-select"> ' + select +
                                '</select></p></div>'+
                                '</div>'+
                                '<br>');
                        },
                        error: function() {
                        }
                    });

                    $("#plan-inner").html(planHTML.join(''));
                },
                error: function() {
                }
            });

            $("#plan_modal").modal();
        };
    </script>

</head>
<body class="page-orange">
<header class="header header-orange header-transparent header-waterfall ui-header">
    <ul class="nav nav-list pull-left">
        <div>
            <a data-toggle="menu" href="#ui_menu">
                <span class="icon icon-lg text-white">menu</span>
            </a>
        </div>
    </ul>
    <ul class="nav nav-list pull-right">
        <div class="dropdown margin-right">
            <a class="dropdown-toggle padding-left-no padding-right-no" data-toggle="dropdown">
                <span class="access-hide">MonarchFlame</span>
                <span class="icon icon-cd margin-right">account_circle</span>
            </a>
            <ul class="dropdown-menu dropdown-menu-right">
                <li>
                    <a class="waves-attach" href="${pageContext.request.contextPath}/admin/staff/plan/staff"><span class="icon icon-lg margin-right">account_box</span>员工中心</a>
                </li>
                <li>
                    <a class="padding-right-cd waves-attach" href="${pageContext.request.contextPath}/admin"><span class="icon icon-lg margin-right">exit_to_app</span>登出</a>
                </li>
            </ul>
        </div>
    </ul>
</header>
<nav aria-hidden="true" class="menu menu-left nav-drawer nav-drawer-md" id="ui_menu" tabindex="-1">
    <div class="menu-scroll">
        <div class="menu-content">

            <a class="menu-logo" href="${pageContext.request.contextPath}/admin"><i class="icon icon-lg">language</i>&nbsp后台</a>
            <ul class="nav">
                <li>
                    <a class="waves-attach" data-toggle="collapse" href="#ui_menu_me">我的</a>
                    <ul class="menu-collapse collapse in" id="ui_menu_me">
                        <li>
                            <a href="${pageContext.request.contextPath}/admin/ceo"><i class="icon icon-lg">account_balance_wallet</i>&nbsp;CEO中心</a>
                        </li>
                    </ul>

                    <a class="waves-attach" data-toggle="collapse" href="#ui_menu_sale">销售部</a>
                    <ul class="menu-collapse collapse in" id="ui_menu_sale">
                        <li>
                            <a href="${pageContext.request.contextPath}/admin/ceo/order-list"><i class="icon icon-lg">account_balance_wallet</i>&nbsp;查看订单列表</a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/admin/ceo/client-list"><i class="icon icon-lg">account_box</i>&nbsp;管理客户信息</a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/admin/ceo/strategy"><i class="icon icon-lg">announcement</i>&nbsp;管理销售策略</a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/admin/ceo/returnOrder"><i class="icon icon-lg">sync_problem</i>&nbsp;处理退货</a>
                        </li>
                    </ul>

                    <a class="waves-attach" data-toggle="collapse" href="#ui_menu_finance">财务部</a>
                    <ul class="menu-collapse collapse in" id="ui_menu_finance">
                        <li>
                            <a href="${pageContext.request.contextPath}/admin/ceo/bill"><i class="icon icon-lg">account_balance_wallet</i>&nbsp;查看账单列表</a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/admin/ceo/finance_returnOrder"><i class="icon icon-lg">account_box</i>&nbsp;确认退货单</a>
                        </li>
                    </ul>

                    <a class="waves-attach" data-toggle="collapse" href="#ui_menu_material">原材料库</a>
                    <ul class="menu-collapse collapse in" id="ui_menu_material">
                        <li>
                            <a href="${pageContext.request.contextPath}/admin/ceo/material-list"><i class="icon icon-lg">account_balance_wallet</i>&nbsp;查看原材料列表</a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/admin/ceo/addMaterial"><i class="icon icon-lg">add</i>&nbsp;添加原材料类型</a>
                        </li>

                        <li>
                            <a href="${pageContext.request.contextPath}/admin/ceo/inMaterial"><i class="icon icon-lg">add_box</i>&nbsp;原材料入库</a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/admin/ceo/outMaterial"><i class="icon icon-lg">announcement</i>&nbsp;原材料出库</a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/admin/ceo/material-record"><i class="icon icon-lg">account_balance_wallet</i>&nbsp;查看原材料记录</a>
                        </li>
                    </ul>

                    <a class="waves-attach" data-toggle="collapse" href="#ui_menu_plan">生产计划科</a>
                    <ul class="menu-collapse collapse in" id="ui_menu_plan">
                        <li>
                            <a href="${pageContext.request.contextPath}/admin/ceo/drawUpPlan"><i class="icon icon-lg">account_box</i>&nbsp;制定生产计划</a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/admin/ceo/plan-list"><i class="icon icon-lg">account_balance_wallet</i>&nbsp;查看生产计划列表</a>
                        </li>
                    </ul>

                    <a class="waves-attach" data-toggle="collapse" href="#ui_menu_product">成品库</a>
                    <ul class="menu-collapse collapse in" id="ui_menu_product">
                        <li>
                            <a href="${pageContext.request.contextPath}/admin/ceo/product-list"><i class="icon icon-lg">account_balance_wallet</i>&nbsp;查看成品列表</a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/admin/ceo/addProduct"><i class="icon icon-lg">add</i>&nbsp;添加产品类型</a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/admin/ceo/inProduct"><i class="icon icon-lg">add_box</i>&nbsp;货物入库</a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/admin/ceo/outProduct"><i class="icon icon-lg">announcement</i>&nbsp;货物出库</a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/admin/ceo/product_returnOrder"><i class="icon icon-lg">announcement</i>&nbsp;处理退货</a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/admin/ceo/product-record"><i class="icon icon-lg">account_balance_wallet</i>&nbsp;查看成品记录</a>
                        </li>
                    </ul>

                    <a class="waves-attach" data-toggle="collapse" href="#ui_menu_workshop">生产车间</a>
                    <ul class="menu-collapse collapse in" id="ui_menu_workshop">
                        <li>
                            <a href="${pageContext.request.contextPath}/admin/ceo/workshop-plan-list"><i class="icon icon-lg">account_box</i>&nbsp;查看生产计划</a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/admin/ceo/workshop-staff-list"><i class="icon icon-lg">account_box</i>&nbsp;查看员工</a>
                        </li>
                    </ul>
            </ul>
        </div>
    </div>
</nav>
<main class="content">
    <div class="content-header ui-content-header">
        <div class="container">
            <h1 class="content-heading">生产要求</h1>
        </div>
    </div>
    <div class="container">
        <div class="col-lg-12 col-sm-12">
            <section class="content-inner margin-top-no">
                <div class="row">

                    <div class="col-lg-8 col-md-12">
                        <div class="card margin-bottom-no">
                            <div class="card-main">
                                <div class="card-inner">
                                    <div class="cardbtn-edit">
                                        <div class="card-heading">查找</div>
                                        <button class="btn btn-flat" id="findRequirement"><span class="icon">check</span>&nbsp;
                                        </button>
                                    </div>
                                    <div class="form-group form-group-label">
                                        <label class="floating-label" >产品名</label>
                                        <input class="form-control maxwidth-edit"  autocomplete="off">
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="card margin-bottom-no">
                            <div class="card-main">
                                <div class="card-inner">
                                    <div class="card-table">
                                        <div class="table-responsive table-user">
                                            <table class="table table-fixed tablesorter" id="requirementTable">

                                            </table>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="card margin-bottom-no">
                            <div class="card-main">
                                <div class="card-inner">
                                    <div class="cardbtn-edit">
                                        <div class="card-heading">根据所选要求制定生产计划</div>
                                        <button class="btn btn-flat" id="drawUpPlan" onclick="javascript:drawUpPlan()"><span class="icon">check</span>&nbsp;
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="col-lg-4 col-md-12">
                        <div class="card margin-bottom-no">
                            <div class="card-main">
                                <div class="card-inner" id="workshop-plan">
                                    <%--                                    <dt>第一车间</dt>--%>
                                    <%--                                    <span class="label-level-expire">面包--%>
                                    <%--                                    <code><span id="days-level-expire">100</span></code>--%>
                                    <%--                                    </span>--%>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div aria-hidden="true" class="modal modal-va-middle fade" id="plan_modal" role="dialog" tabindex="-1">
                    <div class="modal-dialog modal-xs">
                        <div class="modal-content">
                            <div class="modal-heading">
                                <a class="modal-close" data-dismiss="modal" onclick="closeplan()">×</a>
                                <h2 class="modal-title">生产计划确认</h2>
                            </div>
                            <div id="plan-inner" class="modal-inner">

                            </div>
                            <div class="modal-footer">
                                <p class="text-right">
                                    <button class="btn btn-flat btn-brand waves-attach" data-dismiss="modal" id="plan_verify" type="button">确定
                                    </button>
                                </p>
                            </div>
                        </div>
                    </div>
                </div>

                <div aria-hidden="true" class="modal modal-va-middle fade" id="result" role="dialog" tabindex="-1">
                    <div class="modal-dialog modal-xs">
                        <div class="modal-content">
                            <div class="modal-inner">
                                <p class="h5 margin-top-sm text-black-hint" id="msg"></p>
                            </div>
                            <div class="modal-footer">
                                <p class="text-right">
                                    <button class="btn btn-flat btn-brand-accent waves-attach" data-dismiss="modal" type="button" id="result_ok" onclick="location.reload()">知道了
                                    </button>
                                </p>
                            </div>
                        </div>
                    </div>
                </div>
            </section>
        </div>
    </div>
</main>

</body>
</html>
<script>
    $(document).ready(function () {
        //查看生产车间对应计划
        $.ajax({
            type: "POST",
            url: "${pageContext.request.contextPath}/admin/staff/plan/staff/workshopPlan",
            dataType: "json",
            data: {
            },
            success: function(data){
                console.log(data);
                let length = 0;
                for(let ever in data) {
                    length++;
                }
                //把几个车间对应的生产计划放在不同的List中
                console.log(length);
                var workshopPlanHTML=[];
                for (let i=1; i<length+1; i++)
                {
                    var workshopPlanList = eval(data[i+""]);
                    console.log("workshopPlanList");
                    console.log(workshopPlanList);
                    for (let j=0; j<workshopPlanList.length; j++)
                    {
                        let workshopPlan = workshopPlanList[j];
                        workshopPlanHTML.push('<dt>'+workshopPlan.workshop_name+'</dt>\n' +
                            '<span class="label-level-expire">'+workshopPlan.product_name +
                            '<code><span id="days-level-expire">'+workshopPlan.quantity +'</span></code>\n' +
                            '</span>');
                    }
                }
                $('#workshop-plan').html(workshopPlanHTML.join(''));
            },
            error: function() {
                $("#result").modal();
                document.getElementById('msg').innerHTML = `发生了错误`;
            }
        });

        $.ajax({
            type: "POST",
            url: "${pageContext.request.contextPath}/admin/staff/plan/staff/requirementInfoList",
            dataType: "json",
            async:false,
            data: {
            },
            success: function(data){
                var requirementInfoList = eval(data.requirementInfoList);
                var requirementTableHTML=[];
                requirementTableHTML.push(
                    '<thead>\n' +
                    '<tr>\n' +
                    '<td style=" background: #f0faff;"><input type="checkbox" id="checkall" lay-skin="primary" onclick="javascript:selectAll();"></td>\n' +
                    '<th>需求ID</th>\n' +
                    '<th>产品ID</th>\n' +
                    '<th>产品名</th>\n' +
                    '<th>数量</th>\n' +
                    '<th>创建时间</th>\n' +
                    '</tr>\n' +
                    '</thead>' +
                    '<tbody>\n');

                for (let i=0; i<requirementInfoList.length; i++)
                {
                    var requirementInfo = requirementInfoList[i];
                    requirementTableHTML.push(
                        '<tr>\n' +
                        '<th><input type="checkbox" name="check" lay-skin="primary"></th>\n' +
                        '<th name="id">'+ requirementInfo.id +'</th>\n' +
                        '<th name="product_id">'+ requirementInfo.product_id +'</th>\n' +
                        '<th name="name">'+ requirementInfo.name +'</th>\n' +
                        '<th name="quantity">'+ requirementInfo.quantity +'</th>\n' +
                        '<th name="create_time">'+ (new Date(requirementInfo.create_time)).toLocaleString() +'</th>\n' +
                        '</tr>');
                }
                requirementTableHTML.push('</tbody>');
                $('#requirementTable').html(requirementTableHTML.join(''));
            },
            error: function() {
                $("#result").modal();
                document.getElementById('msg').innerHTML = `发生了错误`;
            }
        });

        $("#requirementTable").tablesorter();

        selectAll = function () {
            if (document.getElementById('checkall').checked)
            {
                let elementsByName = document.getElementsByName('check');
                for(let i=0; i<elementsByName.length; i++)
                {
                    let element = elementsByName[i];
                    element.checked = true;
                }
            }
            else
            {
                let elementsByName = document.getElementsByName('check');
                for(let i=0; i<elementsByName.length; i++)
                {
                    let element = elementsByName[i];
                    element.checked = false;
                }
            }

        };
        //关闭订单清空信息
        closeplan = function()
        {
        };

        //下生产计划
        $("#plan_verify").click(function () {
            var plans = document.getElementsByName('aplan');
            for(let i=0; i<plans.length; i++)
            {
                let plan = plans[i];

                var id = plan.children[0].children[0].innerHTML;
                console.log(id);
                var requirement = plan.children[3].children[0].value;
                console.log(requirement);
                var sel=document.getElementById("workshop-select");
                var index = sel.selectedIndex;
                workshop_id= sel.options[index].value;
                $.ajax({
                    type: "POST",
                    url: "${pageContext.request.contextPath}/admin/staff/plan/staff/newPlan",
                    dataType: "json",
                    async:false,
                    traditional:true,
                    data: {
                        product_id:id,
                        requirement:requirement,
                        requirementIdList:requirementIdList[id],
                        workshop_id:workshop_id
                    },
                    success: function(data){
                        if (data.res === 1)
                        {
                            $("#result").modal();
                            document.getElementById('msg').innerHTML = `成功下达生产计划`;
                        }
                        else
                        {
                            $("#result").modal();
                            document.getElementById('msg').innerHTML = `发生了错误`;
                        }
                    },
                    error: function() {
                        $("#result").modal();
                        document.getElementById('msg').innerHTML = `发生了错误`;
                    }
                });
            }
        })
    });

</script>