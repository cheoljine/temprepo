<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/WEB-INF/common/commonPage.jsp" %>
<%@include file="/WEB-INF/common/commonSchedule.jsp" %>
<%@page import="kest.cms.common.util.CommonStringUtil" %>
<%@page import="java.util.List" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@page import="com.ibm.icu.util.Calendar"%>
<%@page import="kest.cms.common.util.CommonDateFormatUtil"%>

<%
	String endDt = CommonDateFormatUtil.getCurrentDate("yyyy-MM-dd");
	String startDt = CommonDateFormatUtil.dateAdd(endDt, "yyyy-MM-dd", Calendar.DAY_OF_MONTH, -7) ;
%>
<style>
input[type=radio], input[type=checkbox] {
		display:none;
	}

input[type=radio] + label, input[type=checkbox] + label {
		font-family: '맑은고딕','Malgun Gothic','나눔고딕',NanumGothic,'돋움',Dotum;
		display:inline-block;
		margin:-2px;
		padding: 4px 12px;
		margin-bottom: 0;
		font-size: 12px;
		line-height: 20px;
		color: #333;
		text-align: center;
		text-shadow: 0 1px 1px rgba(255,255,255,0.75);
		vertical-align: middle;
		cursor: pointer;
		background-color: #f5f5f5;
		background-image: -moz-linear-gradient(top,#fff,#e6e6e6);
		background-image: -webkit-gradient(linear,0 0,0 100%,from(#fff),to(#e6e6e6));
		background-image: -webkit-linear-gradient(top,#fff,#e6e6e6);
		background-image: -o-linear-gradient(top,#fff,#e6e6e6);
		background-image: linear-gradient(to bottom,#fff,#e6e6e6);
		background-repeat: repeat-x;
		border: 1px solid #ccc;
		border-color: #e6e6e6 #e6e6e6 #bfbfbf;
		border-color: rgba(0,0,0,0.1) rgba(0,0,0,0.1) rgba(0,0,0,0.25);
		border-bottom-color: #b3b3b3;
		filter: progid:DXImageTransform.Microsoft.gradient(startColorstr='#ffffffff',endColorstr='#ffe6e6e6',GradientType=0);
		filter: progid:DXImageTransform.Microsoft.gradient(enabled=false);
		-webkit-box-shadow: inset 0 1px 0 rgba(255,255,255,0.2),0 1px 2px rgba(0,0,0,0.05);
		-moz-box-shadow: inset 0 1px 0 rgba(255,255,255,0.2),0 1px 2px rgba(0,0,0,0.05);
		box-shadow: inset 0 1px 0 rgba(255,255,255,0.2),0 1px 2px rgba(0,0,0,0.05);
	}

	 input[type=radio]:checked + label, input[type=checkbox]:checked + label{
		   background-image: none;
		outline: 0;
		-webkit-box-shadow: inset 0 2px 4px rgba(0,0,0,0.15),0 1px 2px rgba(0,0,0,0.05);
		-moz-box-shadow: inset 0 2px 4px rgba(0,0,0,0.15),0 1px 2px rgba(0,0,0,0.05);
		box-shadow: inset 0 2px 4px rgba(0,0,0,0.15),0 1px 2px rgba(0,0,0,0.05);
			background-color:#e0e0e0;
	}
</style>
 <script type="text/javascript" charset="utf-8">
	var dhxLayout,dhxLayout2,dhxGrid,dhxComToolbar,dhxSubLayout;
	var dhxWins,comWin;
	var compState,inspClass;

	window.dhx_globalImgPath = "/images/dhtmlx/";

	$(function() {
		$( "#selectable" ).selectable();
		dhxLayout = new dhtmlXLayoutObject(document.body, "2E");
		dhxLayout.cells("a").hideHeader();
		dhxLayout.cells("a").attachObject("divApprCompSearch");
		dhxLayout.cells("a").setHeight(42);
		dhxLayout.cells("b").setText("DM발송 목록입니다.");
		dhxLayout.cells("b").attachObject("div_bild_list");
		
		dhxGrid = dhxLayout.cells("b").attachGrid();
		dhxGrid.setHeader("<center>접수번호</center>,<center>사업장명</center>,<center>대상품<br>(호기)</center>,<center>접수일자</center>,<center>결재완료일</center>,<center>결과</center>,<center>문서번호</center>,recp_seq");
		dhxGrid.attachHeader("#rspan,#rspan,#rspan,#rspan,#rspan,#rspan,#rspan,#rspan");
		dhxGrid.setInitWidths("100,200,200,100,100,80,100,100");
		dhxGrid.setColAlign("center,center,center,center,center,center,center,center");
		dhxGrid.setColTypes("ro,ro,ro,ro,ro,ro,ro,ro");
		dhxGrid.init();
		dhxGrid.setSkin("dhx_skyblue");
		dhxGrid.setStyle("", "border-right: 1px solid #dbe1ec;border-bottom: 2px solid #dbe1ec","", "");
		//dhxGrid.setColumnHidden(7, true);
		dhxGrid.attachEvent("onRowSelect", function(id,ind,state) {
		});

		//calendarHear
		var t = new dhtmlXCalendarObject(["calendar","calendar2"]);
		t.hideTime();

		function keyEnterCheck(event) {
			if(event.keyCode == "13") jQuery("#btnSearch").trigger("click");
		}
		$("#companyName").keydown(keyEnterCheck);

		//클릭 이벤트 처리
		$('#btnSearch').click(function() {
			if($("#inspectClass").val()==0) {
				alert("검사구분을 선택하세요");
				return;
			} else if($("#inspectClass").val()==1 && $("#inspectType").val()=='') {
				alert("심사종류를 선택하세요.");
				return;
			}
			fnGetDMList();
		});

		// 이벤트 처리
		$("#inspectClass").change(function(event) {
			var getVal = jQuery(this).val();
			inspClass = jQuery(this).val();
			$("#inspectType option:gt(0)").remove();

			if(getVal != "") {
				var datas = {"parent_code_path":"C002.J003." + getVal};
				(new jsAjax()).progress("/getCodeGroupAjax.do", "post", datas, function(data) {

					var list = data.dataList;

					$(list).each(function(idx, obj) {
						$("#inspectType").append("<option value='" + obj.code + "'>" + obj.code_name + "</option>");
					});
					if(getVal == "06") {
					} else if(getVal == "07") {
					} else {
						if(dhxSubLayout != null) dhxLayout.cells("b").detachObject();
					}
				}, "json");
			} else {
				if(dhxSubLayout != null) dhxLayout.cells("b").detachObject();
			}
		});

		$("#inspectType").change(function(event) {
			var getVal = jQuery(this).val();
			var load_type = "";

			switch(getVal) {
				case "01":
				case "02":
				case "03":
					load_type = "2";
					break;
				case "04":
					load_type = "3";
					break;
				case "05":
					load_type = "4";
					break;
			}

			if(load_type == "") {
				if(dhxSubLayout != null) dhxLayout.cells("b").detachObject();
				return;
			}
		});
		function fnGetDMList() {
			dhxGrid.clearAll();
			var limitDtCheck =parseInt(replaceAlll($("#calendar2").val())) - parseInt(replaceAlll($("#calendar").val()));
			if ( limitDtCheck > 60) {
				alert("최대 60일간의 자료만 조회할 수 있습니다.");
				$("#calendar").focus();
				return false;
			}
			var paramsData = $("#searchFrom").serialize();
			$.ajax({
				type: "POST",
				url: "/approval/danger/getDMList.do",
				data: paramsData,
				dataType: "json",
				success: function(data) {
					var inspClass = '';
					var inspType	= '';
					var inspName = "";
					var mng_Num = "";
					var inspResult = "";
					var totalCnt = 0;
					if (data.dmList.length > 0) {
						$.each(data.dmList,function(i,item) {
							inspClass = item.INSPECT_CLASS;
							inspType = item.INSPECT_TYPE;
							inspResult = item.INSP_RESULT;
							if (inspClass == "06"){
								inspName = '안전검사'
							} else {
								inspName = convertToInspName(inspType);
							}
							if ( item.INSP_RESULT == '01') {
								inspResult = "합격";
							} else {
								inspResult = "불합격";
							}
							if (item.MNG_NUM != "" && item.MNG_NUM != undefined) {
								mng_Num = " ("+ item.MNG_NUM +")";
							} else {
								mng_Num = "";
							}
							dhxGrid.addRow(item.LEDGER_SEQ,[item.RECP_NUMBER,
							                              item.COMPANY_NAME,
							                              item.FORM_NUM + mng_Num ,
							                              item.REGISTER_DT,
							                              item.INSP_EXPECT_DT,
							                              inspResult,
   							     						  item.DOCNUMBER,
   							     						  item.RECP_SEQ
							     						],i);
							totalCnt = i;
						});
					}
					//fnAppendBtns(inspClass,inspType);
					dhxLayout.cells("b").setText("DM발송 목록입니다. ( 총 " + totalCnt + "건이 검색 되었습니다.)"  );
					var arr = [];
					var recpSeqOfArr = [];
					var countOfArr = [];
					var result = "";
					dhxGrid.forEachRow(function(id){
						arr.push(dhxGrid.cells(id,7).getValue());
						result = foo(arr);
					});
					recpSeqOfArr = (result[0] + "").split(",");
					countOfArr =(result[1] + "").split(",");
					for (var i = 0; i < recpSeqOfArr.length; i++) {
						//dhxGrid.setRowspan(findByRowId(recpSeqOfArr[i]),0,countOfArr[i]);
					} 
				}
			});
		}
		function foo(arr) {
		    var a = [], b = [], prev;
		    arr.sort();
		    for ( var i = 0; i < arr.length; i++ ) {
		        if ( arr[i] !== prev ) {
		            a.push(arr[i]);
		            b.push(1);
		        } else {
		            b[b.length-1]++;
		        }
		        prev = arr[i];
		    }
		    return [a,b];
		}
		function findByRowId(recpSeq){
			var result = [];
			dhxGrid.forEachRow(function(id){
				if ( dhxGrid.cells(id,7).getValue() == recpSeq ) {
					result.push(id); 
				}
			});
			result.sort();
			return result[0]
		}
		function convertToInspName (name) {
			var returnName = '';
			if (name == '01') {
				returnName = '서면심사';
			} else if (name == '02') {
				returnName = '제품심사';
			} else if (name == '03'){
				returnName = '형식별심사';
			} else if (name == '04') {
				returnName = '기생심사';
			} else {
				returnName = '확인심사';
			}
			return returnName;
		}
		$("#div_report_list").on("click","button", function () {
			alert($(this).closest("button").attr("id"));
		});
	});
	function replaceAlll(value) {
		return value.replace(/\-/g,'');
	}
	function fnAppendBtns(inspClass, inspType) {
		$("#div_report_list").html("");
		if ( inspClass == '06') { //안전검사
			$("#div_report_list").append("<button type='button' class='btnGray2' id='33'>검사결과통보서</button><button type='button' class='btnGray2' id='34'>안전검사결과보고서</button>"
					+ "<button type='button' class='btnGray2' id='31'>안전검사불합격통지서</button>"
					+"<button type='button' class='btnGray2' id='31'>안전검사합격증명서</button><button type='button' class='btnGray2' id='31'>검사기록표</button>");
		} else {
			if ( inspType == '01') { //서면심사
				$("#div_report_list").append("<button type='button' class='btnGray2' id='33'>심사결과통보서</button><button type='button' class='btnGray2' id='34'>심사결과통지서</button><button type='button' class='btnGray2' id='31'>서면심사결과서</button>");
			} else { // 안전인증 , 서면심사 제외한 나머지
				$("#div_report_list").append("<button type='button' class='btnGray2' id='39'>안전인증서</button><button type='button' class='btnGray2' id='34'>심사결과통보서</button>"
					+ "<button type='button' class='btnGray2' id='31'>심사결과통지서</button>"
					+"<button type='button' class='btnGray2' id='31'>심사결과보고서</button><button type='button' class='btnGray2' id='31'>안전인증스티커</button>");
			}
		}
	}
	function docPdf2(aseq,fileName) {
		$("#aseq").val(aseq);
		if ( aseq == '40' || aseq == '1' || aseq == '2' ) {
			$("#fileName").val("${attechPopup.COMPANY_NAME}"+"_"+fileName+".pdf");
		} else {
			$("#fileName").val("${attechPopup.RECP_NUMBER}"+"_"+fileName+".pdf");
		}
		$.ajax({
			type: "POST",
			url: "/approval/danger/docInfoCheck.do",
			data: $("#frm").serialize(),
			dataType: "text",
			success: function(data) {
				if(data == "true") {
					$("#frm").attr("target", "_self");
					$("#frm").attr("action", "/pdf/pdfMgrCtl.do");
					$("#frm").submit(); 
				}else {
					if(data == "false") {
						alert("문서 출력정보를 저장해야합니다. ");
					} else if(data == "false2") {
						alert("합격(적합) 판정을 받은 대상품이 없습니다.");
					} else if(data == "false3") {
						alert("불합격(부적합) 판정을 받은 대상품이 없습니다.");
					} else if(data == "false4") {
						alert("보완 판정을 받았거나 보완 이력이 있는 대상품이 없습니다.");
					} else if(data == "false5") {
						alert("부적합 또는 보완 판정을 받았거나 보완 이력이 있는 대상품이 없습니다.");
					} else if(data ==  "false7") {
						alert("안점검사 불합격 대상품이 없습니다.");
					} else {
						alert("합격(적합) 또는 불합격(부적합) 판정을 받은 대상품이 없습니다.");
					}
				}
			}
		});
	}
</script>

<div id="divApprCompSearch" style="padding:5px 0px 0px 5px;">
<form name="searchFrom" id="searchFrom">
<input type="hidden" name='apprStartDt' id='apprStartDt' >
<input type="hidden" name='apprEmdDt' id='apprEndDt' >
<input type="hidden" name="regSearchType" id="regSearchType">
<input type="hidden" name="bldName" id="bldName" >
<input type="hidden" id="recpNumber" name="recpNumber" >
<input type="hidden" id="inspType" name="inspType">
<input type="hidden" id="recp_seq" name="recp_seq" >
<input type="hidden" id="appr_seq" name="appr_seq" >
<table>
	<tr>
		<td>
			&nbsp;지사선택
			<select id="machcode" name="machcode" style="width:110px; position:relative; top:2px;">
				<option value="">전체</option>
				<c:forEach var="item" items="${branchCode }">
				<option value="${item.code}">${item.code_name }</option>
				</c:forEach>
			</select>
			&nbsp;검사종류
			<input type="radio" id="radio1" name="inspectClass" value="02" checked>
      		 <label for="radio1">안전인증</label>
    		<input type="radio" id="radio2" name="inspectClass"value="01">
      		 <label for="radio2">제품심사</label>
      		 <input type="radio" id="radio3" name="inspectClass"value="06">
      		 <label for="radio3">안전검사</label>
			<span style="margin-left: 200px">결재일자</span>
			<input type="text" id="calendar" name="calendar" class="inputText" style="width:68px;" value="<%=startDt%>">-<input type="text" id="calendar2" name="calendar2" class="inputText" style="width:68px;" value="<%=endDt%>">
			<input id="btnSearch" type="button" value="검색" class="btnGray" style="width:50px;">
		</td>
	</tr>
</form>
</div>

<div id="div_bild_list" style="height:100%;"></div>

<OBJECT ID="Viewer1"
	CLASSID="CLSID:89150B7A-45A8-457D-927E-D1227DF809DC"
	CODEBASE="/ReportExpress/instrf/refree.cab#version=1,0,0,7"
	STYLE="display: none">
</OBJECT>
<!--CODEBASE="http://www.cabsoftware.com/rxviewer/inst/cab/refree.cab#version=1,0,0,7"-->
