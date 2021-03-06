package ticket.dao.face;

import java.util.List;

import org.apache.ibatis.annotations.Param;

import ticket.dto.Poster;
import ticket.utils.Paging;

public interface PosterDao {

	public void insert(Poster info);

	
	/**
	 * @param paging 
	 * @최종수정일: 2018.12.10
	 * @Method설명: 장르로 검색해서 가져옴 
	 * @작성자: 박주희
	 */
	public List<Poster>selectBygenreIdx(@Param(value="genreIdx") int genreIdx, 
			@Param(value="paging")Paging paging);
	
	/**
	 * @최종수정일: 2018.12.11
	 * @Method설명:페이징에 필요한 모달에 들어갈 리스트 갯수 
	 * @작성자: 박주희
	 */
	public int selectCntBygenreIdx(int genreIdx);
	
	/**
	 * @최종수정일: 2018.12.10
	 * @Method설명: 공연아이디로 전체 리스트를 불러옴
	 * @작성자: 박주희
	 */
	public List<Poster>selectBypfmIdx();
	
	/**
	 * @최종수정일: 2018.12.10
	 * @Method설명:공연아이디로 전체 리스트를 불러옴 (뮤지컬)
	 * @작성자:박주희
	 */
	public List<Poster>selectBypfmIdxMu();
	
	/**
	 * @최종수정일: 2018.12.11
	 * @Method설명:공연아이디로 전체 리스트를 불러옴 (가족)
	 * @작성자:박주희
	 */
	public List<Poster>selectBypfmIdxFam();
	
	
	/**
	 * @최종수정일: 2018.12.10
	 * @Method설명: 포스터를 이름으로 검색해서 리스트를 얻어옴
	 * @작성자:박주희
	 */
	public List<Poster>selectPosterByName(String name);
	/**
	 * @최종수정일: 2018.12.10
	 * @Method설명: 포스터를 이름으로 검색해서 리스트를 얻어옴(뮤지컬)
	 * @작성자:박주희
	 */	
	public List<Poster>selectPosterByNameMu(String name);
	
	/**
	 * @최종수정일: 2018.12.11
	 * @Method설명: 포스터를 이름으로 검색해서 리스트를 얻어옴(가족)
	 * @작성자:박주희
	 */	
	public List<Poster>selectPosterByNameFam(String name);
}
