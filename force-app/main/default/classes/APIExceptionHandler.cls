/**
 * @description 예외 처리를 담당하는 인터페이스
 */
public interface APIExceptionHandler {
    /**
     * @description 예외를 처리하고 적절한 응답을 생성
     * @param aEx 발생한 예외 객체
     * @param aRes RestResponse 객체
     */
    void handle(Exception aEx, RestResponse aRes);
}
