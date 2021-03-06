<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<style type="text/css">
#userinfo{
	background-color: #CCC;
}

#userProfile{
	width: 150px;

	
}
#userNick{
	font-weight: bolder;
	font-size: 2em;
}

#preferTheme{

	border: 1px solid #CCC;
	
	/*아티스트 리스트 뽑을 때 사용했던 float 해제  */
	clear: left;
}

.thumbnail{
	float: left;
}

#selectedArt {
	/*아티스트 리스트 뽑을 때 사용했던 float 해제  */
	clear: left;
	
	border: 1px solid #CCC;
}
#searchArtist{
	display: none;
}
</style>


<script type="text/javascript">
$(document).ready(function(){

	
	// 추가한 아티스트에서 X 클릭시 삭제하기
	$('#selectedArt').on('click', '.glyphicon-remove', function(){
		$(this).parent().remove();
	});

	
	// 취향설정 완료 버튼 눌렀을 때 
	$('#preferChoice').click(function() {
		
		// 테마에서 선택된 체크박스 값 담기
		 var checkboxes = [];
	    $("input[name='themeIdx']:checked").each(function(i) {
	    	checkboxes.push($(this).val());
	    });
		
	    console.log("체크된 값");
	    console.log(checkboxes);
		console.log(checkboxes.length);
		
		if (checkboxes.length < 1) {
			alert ("하나는 선택해야함");
			return;
		} 
		
		// 선택한 아티스트 값 처리하기
		var selectedList = $('#selectedArt').find('div');
		console.log("선택 리스트 길이 :"+$(selectedList).length);
		
		var artistList = [];
		
		// 선택된 아티스트 가져와서 배열에 저장하기
		selectedList.each(function(i) {
			// data-paidx 가져오기! data-* 의 반환타입이 JSON 이라서 이렇게 받음
			var p = $(this).data('paidx');
			console.log(p);

			artistList.push(p);
		}); // each end
		
		console.log("체크된 아티스트 값:"+artistList);
		
		
		$.ajax({
			type :"POST"
			, url :"/mypage/prefer"
			, data : {
				"themeIdx":checkboxes
				,"artistIdx" : artistList
			}
			, success:function(data) {
				console.log ("성공");
			}
		
		}); // ajax end
	}); // click end
	
	
	
	$('#btn_search').click(function() {
		
		console.log("검색 버튼 함수 실행");
		searchArtistAjax();
	});
	
	
	// 아티스트 검색을 위한 ajax 통신
	function searchArtistAjax(){
		$.ajax({
			url: "/mypage/searchArtist"
			, method : "POST"
			, data: {"name": $('#artist_text').val() }
			, dataType: "json"
			, success : function(d){
				console.log(d);
				console.log("ajax 통신 성공:" +d);
// 				var artists = d.artists;
				var artists = d;
				
				// 아티스트 검색 결과 띄워주기
				$('#searchArtist').show();
				$('#searchArtist').html('');
				
				if(artists.length == 0){
					$('#searchArtist').html('검색 결과가 없습니다.');
				}
				var unit = 1;
				var unitDiv = $('<div class="resUnit">'); 
				var ul = $('<ul>')
				
				artists.forEach(function(artist){
// 					console.log(artist)
				
					// 하나의 검색 결과 저장할 div
					var resLi = $('<li>');
					resLi.data('aIdx', artist.artistIdx); // 커스텀 태그로 artist 정보 삽입
					resLi.data('aName', artist.name); // 커스텀 태그로 artist 정보 삽입
					
					// 아티스트 이미지 띄울 태그
					var img = $('<img>');
					img.attr('src', artist.imgUri);
					// 아티스트명 띄울 태그
					var name = $('<p>');
					name.text(artist.name);

					resLi.append(img);
					resLi.append(name);
					resLi.append("<input type='button' class='addArtist' value='추가'>")
					
					// 모달의 검색 결과 창에 결과 태그들 추가
					$('#searchArtist').append(unitDiv.append(resLi));
					
				}); // foreach end 
			} // success end
			, error: function(){
				console.log("아티스트 검색 실패");
			} // error end
			
		});// ajax end
		
	}// function  end
	
}); //ready end


// 아티스트 리스트에서 아티스트 선택 시 반응할 메소드
function artChoice(artistIdx, name){
	console.log("아티스트 인덱스:"+ artistIdx)
	// 추가하기 위해 눌렀을 때
	var isExist = false ;
	var selectedList = $('#selectedArt').find('div');
	selectedList.each(function(i) {
		if($(selectedList[i]).data('paidx')==artistIdx){
			isExist = true;
			
			// 중복되면 삭제하기!
			$(selectedList[i]).remove();
			return false ; // each 문 종료
		}
	});
	if(isExist){
		return; // 추가하는 메소드 종료
	}
	
	// 선택한 결과 태그 추가하기
	var  selected = $("<div>");
	selected.data('paidx', artistIdx );
	selected.data('artistName', name);
	console.log("선택한 아티스트paidx:"+selected.data('paidx'));
	
	var aName =$('<span>');
	aName.text(name);
	selected.append(aName);
	selected.append("<span class='glyphicon glyphicon-remove' ></span>")
	
	$('#selectedArt').append(selected);
	
}





</script>


    
<h1>마이페이지 선호 찜</h1>
<hr>
<div id = "userinfo">
	<div class = "form-inline">
	
		<img id = "userProfile" src="${loginUser.profile }"  class="img-circle"/>
		<span id="userNick">${loginUser.nick }</span> <small>님 안녕하세요</small>
		<button id="userInfoChange" class="btn btn-default">정보 변경</button>
		<span>입금 대기</span><span>예매 완료</span><span>취소 현황</span>
	</div>
	
	
</div>

<hr>
<h3>선호 아티스트 선택</h3>
<div id ="preferArtist">


<div class="search_in">
	<fieldset>
       <div class="wrap_form_input"><!-- form wrapper -->
       	<input type="text" name="artist_text" id="artist_text" class="inputType" value="">
       	<label for="artist_text" class="place_holder" style="display: none;">아티스트 검색</label>              
		</div>                                                          
    <button type="button" class="btn_icon search_m" title="검색" id="btn_search"><span class="btn_comm btn_search">검색</span></button>
    </fieldset>
</div>



<div style="/*display: none; */">
	<div id="searchArtist">
		
	</div>
</div>


<c:forEach items="${aList }" var="a">
    <div class="thumbnail" style="width: 15%;" onclick ="artChoice('${a.artistIdx}','${a.name }');">
      <img style = "width: 80px;" src="${a.imgUri }" class="img-circle" >
      <div class="caption">
        <p style="text-align: center;">${a.name }</p>
    </div>
  </div>
	
</c:forEach>

<div id = "selectedArt">
	<c:forEach items="${paList }" var ="pa">
	<c:if test ="${! empty  pa}">
	<div data-paidx="${pa.artistIdx }">
		<span>${pa.artistName } </span>
		<span class='glyphicon glyphicon-remove' ></span>
	</div>
	</c:if>
	</c:forEach>
</div>
</div>

<div id ="preferTheme">
<hr>
<h3>선호 테마 선택</h3>

<c:forEach items="${tList }" var="t">
	<label class="checkbox-inline" style ="width:30%">
		<input type="checkbox" name ="themeIdx" value="${t.themeIdx}" <c:forEach items="${ptList }" var="p">
			<c:if test="${t.themeIdx eq p.themeIdx}">
			checked="checked"
			</c:if>
		 </c:forEach> /> ${t.themeName }
	</label>
</c:forEach>

</div>

<button id="cancel" class="btn btn-default"> 취소 </button><button id="preferChoice" class="btn btn-default"> 취향 설정 완료 </button>