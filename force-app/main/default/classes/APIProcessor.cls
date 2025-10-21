/**
 * @description 실제 비즈니스 로직 처리를 담당하는 인터페이스
 */
public interface APIProcessor {
    /**
     * @description 요청을 처리하고 응답을 생성
     * @param aReq RestRequest 객체
     * @param aRes RestResponse 객체
     */
    void process(RestRequest aReq, RestResponse aRes);
}
