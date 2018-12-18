<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<script type="text/javascript"
	src="https://cdn.iamport.kr/js/iamport.payment-1.1.5.js"></script>
	<!-- 아임포트 스크립트 이게 없으면 실행이 안됨.. -->
 <link rel="stylesheet" href="/resources/css/onestop.css" type="text/css" /> 
<script src="http://code.jquery.com/jquery-latest.min.js"></script>
<script src="http://code.jquery.com/ui/1.12.1/jquery-ui.js"></script>    
<script src="https://ssl.daumcdn.net/dmaps/map_js_init/postcode.v2.js"></script>

<script>
function openZipSearch() {
	new daum.Postcode({
		oncomplete: function(data) {
			$('[name=delvyAddr]').val(data.address+data.buildingName);
		}
	}).open();
}
	$(document).ready(
			function() {
				var IMP = window.IMP; // 생략해도 괜찮습니다.
				IMP.init("imp49321816"); // "imp00000000" 대신 발급받은 "가맹점 식별코드"를 사용합니다.

				$("#payment").click(function() { //payment 버튼 클릭시 
// 					console.log("클릭됐습니다.");
					requestPayment(); //결제 실행 함수
				});

				$("#merchant_uid").val( //merchant_uid 설정법 공연명_book_idx_날짜
						'공연명' + '_' + 'book_idx'
								+ '_' + new Date().getTime());
				$("#back").click(function() {
					history.go(-1); //이전으로 
				});
				$("#cancel").click(function(){ //결제취소 버튼 
					$.ajax({
						url: "/ticket/cancel"
						, method : "POST"
						, dataType: "json"
						, data: {
							payIdx : '3' //payment payIdx 로 조회하여 취소 
						}
						, success : function(d){
							console.log(d);
							if(d=='fail'){
								alert("이미 취소된 거래입니다.");
							}else {
								alert(d);
							}
						}, error: function(){
							console.log("검색 실패");
						}
						});
					  		
				});
			});

	function setDeliveryType(e){
		//console.log(e);
		if(e=='DV03'){
			$('#part_delivery_info').show();
		}else{
			$('#part_delivery_info').hide();
		}
	}
	function requestPayment() {
		console.log("무슨방법?:"+$('input[name="payMethodCode"]:checked').val());
		IMP.request_pay({
			pg : 'uplus', //PG사 - 'kakao':카카오페이, 'html5_inicis':이니시스(웹표준결제), 'nice':나이스페이, 'jtnet':제이티넷, 'uplus':LG유플러스, 'danal':다날, 'payco':페이코, 'syrup':시럽페이, 'paypal':페이팔
			pay_method : $('input[name="payMethodCode"]:checked').val(), //결제방식 - 'samsung':삼성페이, 'card':신용카드, 'trans':실시간계좌이체, 'vbank':가상계좌, 'phone':휴대폰소액결제
			merchant_uid : $("#merchant_uid").val(), //고유주문번호 - random, unique 해야됨 중복되면 결제가 되지 않음 (없으면 안됨)
			amount : $("#amount").val(), //결제금액 - 필수항목 ( 없으면 안됨.)
			buyer_email : $("#buyer_email").val(), //주문자Email - 선택항목 해당 메일로 주문결제 내역을 보내줌 
			buyer_name : $("#buyer_name").val(), //주문자명 - 선택항목
			buyer_tel : $("#buyer_tel").val(), //주문자연락처 - 필수항목, 누락되면 PG사전송 시 오류 발생!!
			buyer_addr : $("#buyer_addr").val(), //주문자주소 - 선택항목 
			//buyer_postcode : '123-456', //주문자우편번호 - 선택항목
			m_redirect_url : 'https://www.yourdomain.com/payments/complete' //모바일결제후 이동페이지 - 선택항목, 모바일에서만 동작

		}, function(rsp) { // callback - 결제 이후 호출됨, 이곳에서 DB에 저장하는 로직을 작성한다
			if (rsp.success) { // 결제 성공 로직
				var msg = '결제가 완료되었습니다.';
				msg += '고유ID : ' + rsp.imp_uid;
				msg += '상점 거래ID : ' + rsp.merchant_uid;
				msg += '결제 금액 : ' + rsp.paid_amount;
				msg += '카드 승인번호 : ' + rsp.apply_num;
				msg += '결제 수단 : ' + rsp.pay_method;
				msg += '결제 시간 : ' + rsp.paid_at;
				msg += '[rsp.success]';

				// 결제 완료 처리 로직
				//[1] 서버단에서 결제정보 조회를 위해 jQuery ajax로 imp_uid 전달하기
				jQuery.ajax({
					url : "/ticket/payment",//해당 URL 로 데이터 전송(현재는 payment DB에 저장됨 ) 
					//cross-domain error가 발생하지 않도록 동일한 도메인으로 전송
					type : 'POST',
					dataType : 'json',
					data : {
						// rsp객체를 통해 전달된 데이터를 DB에 저장할 때 사용한다
						impUid : rsp.imp_uid,
						merchantUid : rsp.merchant_uid,
						payMethod : rsp.pay_method, //결제정보
						pfmIdx : 14, //공연번호 
						paidAmount : rsp.paid_amount, //결제금액
						buyerName : rsp.buyer_name, //구매자 이름 
						buyerEmail : rsp.buyer_email, //구매자 메일 
						useridx : "${loginUser.userIdx }", //유저 idx
						paid_at : rsp.paid_at //필요없음
					}

				}).done(function(data) {
					//[2] 서버에서의 응답 처리
					if (data == 'success') {
						var msg = '결제가 완료되었습니다.';
// 						msg += '\n고유ID : ' + rsp.imp_uid;
// 						msg += '\n상점 거래ID : ' + rsp.merchant_uid;
// 						msg += '\n결제 금액 : ' + rsp.paid_amount;
// 						msg += '\n카드 승인번호 : ' + rsp.apply_num;
// 						msg += '\n[done]';

						alert(msg);

					} else {
						var msg = '결제가 제대로 되지 않았습니다. 자동 취소 처리 하였습니다.'
						//[3] 아직 제대로 결제가 되지 않았습니다.
						//[4] 결제된 금액이 요청한 금액과 달라 결제를 자동취소처리하였습니다.
						alert(msg);
					}
				});
			} else { // 결제 실패 로직
				var msg = '결제에 실패하였습니다.';
				msg += '에러내용 : ' + rsp.error_msg;
			}
			alert(msg);
			//여기서 메인으로 돌아가는 코드 작성 
		});
	}
</script>
${loginUser.userIdx };
<div class="section_onestop">
<div class="wrap_select">
<!--  -->
<div class="box_how">
	<h3 class="select_tit">수령방법을 선택하세요</h3>
	<ul class="list_receipt_how" id="partDeliveryType" style="">
	<li id="delvyType02">
	<label>
	<input type="radio"id="delvyTypeCode02" name="delvyTypeCode" value="DV02" onclick="setDeliveryType(this.value);"
				class="radio_delvy_type" title="현장수령">
	<span class="txt_lab" id="delvyTypeNameDV0002"
				style="">&nbsp;현장수령</span></label></li>
	<li id="delvyType03">
	<label><input type="radio"id="delvyTypeCode03" name="delvyTypeCode" value="DV03" class="radio_delvy_type" onclick="setDeliveryType(this.value);"
				title="배송">
				<span class="txt_lab" id="delvyTypeNameDV0003"
				style="">&nbsp;배송(2,500원)</span></label></li>			
	</ul>
	<div class="txt" id="txtDeliveryInfo">
		<span>예매완료(결제익일) 기준으로 4~5일 이내 배송됩니다.(주말/공휴일을 제외한 영업일 기준)</span>
	</div>
	<div class="box_info_use box_gray">
	<!-- 현장수령 선택시-->
		<h4 class="tit_receipt">주문자정보</h4>
		<div class="box_inp_opt">
			<table class="tbl">
				<caption class="hide"></caption>
				<colgroup>
					<col style="width: 43px;">
					<col style="width: 90px;">
					<col style="width: 50px;">
					<col style="width: 195px;">
					<col style="width: 50px;">
					<col style="width: 150px;">
				</colgroup>
				<tbody>
					<tr>
						<th class="txt_gray" style="width: 70px;" id="labUserName">이름<span class="require">*</span></th>
						<td>
							<div class="wrap_form_input">
								<input type="text" name="buyerName" id="buyerName"
									class="inputType inp_txt inp_w77" value="">
							</div>
						</td>
						<th class="txt_gray" style="width: 80px;">연락처<span class="require">*</span></th>
						<td>
							<div class="wrap_form_input">
							<input type="text" name="buyer_tel" id="buyer_tel"
									class="inputType inp_txt inp_w150" value="">
							</div>
						</td>
						<th class="txt_gray" style="width: 75px;">이메일<span class="require">*</span></th>
						<td>
							<div class="wrap_form_input">
								<!-- form wrapper -->
								<input type="text" name="email" id="buyer_email"
									class="inputType inp_txt inp_w150" value=""> <label
									for="email" class="place_holder"></label>
							</div>
						</td>
					</tr>
				</tbody>
			</table>
			<p class="txt_more txt_gray">입력하신 이메일로 예매확인 내역을 보내드립니다.</p>
		</div>
	</div>
	<div class="box_location box_gray" id="part_delivery_info" style="display: none;">
	<!-- 일반배송 선택시-->
	<h4 class="tit_receipt">
			배송지 정보 <span class="box_check"> <label><input
					type="checkbox" id="copyDelvyAddr"> 주문자정보와 동일</label>
			</span>
		</h4>
		<div class="box_inp_opt">
		<div class="box_inp_opt">
				<table class="tbl ">
					<caption class="hide"></caption>
					<colgroup>
						<col style="width: 72px;">
						<col style="width: 240px;">
						<col style="width: 60px;">
						<col style="width: 198px;">
					</colgroup>
					<tbody>
					<tr>
					<th class="txt_gray">수령인<span class="require">*</span></th>
					<td>
					<div class="wrap_form_input">
									<!-- form wrapper -->
					<input type="text" name="buyerName" id="buyerName"
					class="inputType inp_txt inp_w190" value=""> <label
					for="delvyName" class="place_holder"></label>
						</div>
					</td>
					<!--  -->
					<th class="txt_gray">연락처<span class="require">*</span></th>
							<td>
								<div class="wrap_form_input">
									<!-- form wrapper -->
									<input type="hidden" name="delvyTel" id="delvyTel"
										class="inputType inp_txt inp_w190" value=""> <input
										type="text" name="delvyTel1" id="delvyTel1"
										class="inputType inp_txt inp_w60" value="" maxlength="4">
									<input type="text" name="delvyTel2" id="delvyTel2"
										class="inputType inp_txt inp_w60" value="" maxlength="4">
									<input type="text" name="delvyTel3" id="delvyTel3"
										class="inputType inp_txt inp_w60" value="" maxlength="4">
									<label for="delvyTel" class="place_holder"></label>
								</div>
							</td>
						</tr>
						<tr>
							<th class="txt_gray txt_top" rowspan="3">주소<span
								class="require">*</span></th>
							<td colspan="3">
								<button type="button" class="box_inp_btn" id="btnSearchAddress" onclick="openZipSearch()">우편번호</button></td>
						</tr>
						<tr>
							<td colspan="3" class="td_pd"><span class="wrap_form_input">
									<!-- form wrapper -->
									<input type="text" name="delvyAddr"
									id="buyer_addr" class="inputType inp_txt inp_l2" value=""
									> <label for="delvyAddr"
									class="place_holder"></label>
							</span> 
							</td>
						</tr>
						</tbody>
						</table>
						</div>
						
		</div>
	</div>
</div>
<!--결제방법  -->

<!-- 결제 수단 -->
<div id="partPaymentInfo" class="box_payment" style="">
<h3 class="select_tit">결제수단을 선택하세요</h3>
<ul class="list_receipt_how">
<li id="payMethod001">
	<label>
	<input type="radio" id="pay_method1" name="payMethodCode" value="card" title="신용카드" class="radio_pay_metohd_code"> 
	<span id="payMethodName001" class="txt_lab radio_pay_metohd_label">신용카드</span>
	</label>
</li>
<li id="payMethod003">
	<label>
    <input type="radio" id="pay_method2" name="payMethodCode" value="samsung" class="radio_pay_metohd_code"> 
	<span id="payMethodName003" class="txt_lab radio_pay_metohd_label" style="">삼성페이</span>
	</label>
</li>
<li id="payMethod002">
	<label>
	<input type="radio" id="pay_method3" name="payMethodCode" value="phone" title="휴대폰 결제" class="radio_pay_metohd_code"> 
	<span id="payMethodName002" class="txt_lab radio_pay_metohd_label" style="">휴대폰 결제</span>
	</label>
</li>
</ul>
</div>
<!-- 결제수단 -->
<!-- 결제 동의 -->
<div id="partCheckAgree" class="box_cont box_receipt">
	<ul class="box_agree" style="list-style: none;">
		<li class="list_agree frt">
			<div class="select_tit">
				예매자동의
				<div class="tit_check_r">
					<input type="checkbox" id="chkAgreeAll" name="chkAgreeAll"
						title="전체 동의합니다." class=""> <label for="chkAgreeAll"><span
						class="txt_lab">전체동의</span></label>
				</div>
			</div>
		</li>
		<li class="list_agree">
			<div class="tit_check">
				<input type="checkbox" id="chkAgree01" name="chkAgree"
					title="예매 및 취소 수수료/ 취소기한을 확인하였으며 동의합니다." class=""> <label
					for="chkAgree01"><span class="txt_lab">예매 및 취소 수수료/
						취소기한을 확인하였으며 동의합니다.</span></label>
			</div>
			<div class="box_ar_info">
				<div class="tb_date">
					<table class="tbl ">
						<caption class="hide"></caption>
						<colgroup>
							<col style="width: 226px;">
							<col style="width: 326px;">
						</colgroup>
						<thead class="tb_date_th">
							<tr>
								<th class="txt_gray">취소방법</th>
								<th class="txt_gray">취소수수료</th>
							</tr>
						</thead>
						<tbody id="partCancelFeeList2">
							<tr>
								<td>전액환불</td>
								<td>없음</td>
							</tr>
						</tbody>
					</table>
				</div>
			</div>
		</li>
		<li class="list_agree">
			<ul>
				<li class="float_l">
					<div class="tit_check">
						<input type="checkbox" id="chkAgree05" name="chkAgree"
							title="결제대행 서비스 표준이용약관"> <label for="chkAgree05"><span
							class="txt_lab">결제대행 서비스 표준이용약관</span></label>
					</div>
				</li>
				<li class="float_r">
					<div class="tit_check">
						<input type="checkbox" id="chkAgree04" name="chkAgree"
							title="개인정보 제3자 제공 동의 및 주의사항"> <label for="chkAgree04"><span
							class="txt_lab">개인정보 제3자 제공 동의</span></label>
						<!-- 레이어 보기 임시 onclick 이벤트 개발시 삭제 -->
					</div>
				</li>
			</ul>
		</li>
	</ul>
</div>
<!-- 결제 동의 -->

</div>
<!-- 티켓 정보 -->
<div class="wrap_ticket_info">
		<h2 class="logo_onestop">
			<a href="#none"><img src="https://cdnticket.melon.co.kr/resource/image/web/onestop/logo_onestop.png" alt="바나나 티켓"></a>
		</h2>
		<div class="box_info">
		<h3 class="select_tit select_t txt_prod_name" title="공연제목">공연제목들어가는자리</h3>
			<div class="box_ticket">
				<ul class="box_ticket_list" style="list-style: none;">
					<li class="nth nth1 txt_prod_schedule">공연 날짜 및 시간 넣는 곳 </li>
					<li class="nth nth2 txt_ticket_info">공연 좌석 선택수(몇석)<br>VIP석 1층 Q열 038번</li>
				</ul>
			</div> <!-- box_ticket -->
		</div><!-- box_info -->
		<div class="box_info">
		<h3 class="select_tit">결제금액</h3>
		<div class="box_ticket">
				<div class="box_total_inner">
					<p class="tk_b">
						<span class="tk_tit">티켓금액</span><span class="pay pay_comp">
						<span id="ticketPriceTotal">88,000</span>원</span>
					</p>
				</div>
		</div>
		</div><!-- box_info -->
</div>
<!-- 티켓 정보 -->
</div>


<table id="pay" style="margin: 0 auto;">
<!-- 	<tr> -->
<!-- 		<th>결제수단</th> -->
<!-- 		<td><select id="pay_method"> -->
<!-- 				<option value="card" selected>카드</option> -->
<!-- 				<option value="samsung">삼성페이</option> -->
<!-- 				<option value="phone">휴대폰 소액결제</option> -->
<!-- 		</select></td> -->
<!-- 	</tr> -->
	<tr>
		<th>주문번호</th>
		<td><input type="text" id="merchant_uid" /></td>
	</tr>
	<tr>
		<th>금액</th>
		<td><select id="amount">
				<option value="100" selected>1만원</option>
				<option value="20000">2만원</option>
				<option value="30000">3만원</option>
				<option value="50000">5만원</option>
				<option value="100000">10만원</option>
		</select></td>
	</tr>

<!-- 	<tr> -->
<!-- 		<th>성함</th> -->
<%-- 		<td><input type="text" id="buyer_name" name="buyerName" value="${loginUser.name }"></td> --%>
<!-- 	</tr> -->
<!-- 	<tr> -->
<!-- 		<th>전화번호</th> -->
<%-- 		<td><input type="text" id="buyer_tel" value="${loginUser.phone }"></td> --%>
<!-- 	</tr> -->
<!-- 	<tr> -->
<!-- 		<th>배송주소</th> -->
<%-- 		<td><input type="text" id="buyer_addr" value="${loginUser.addr }"></td> --%>
<!-- 	</tr> -->
<!-- 	<tr> -->
<!-- 	<th>이메일 주소</th> -->
<%-- 		<td><input type="text" id="buyer_email" value="${loginUser.email }" ></td> --%>
<!-- 	</tr> -->
</table>

<button id="payment">결제하기</button>
<button id="back">돌아가기</button>
<button id="cancel">결제취소</button>

