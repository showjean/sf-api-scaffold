/**
 * @description 기본 예외 핸들러 (예제)
 */
public class APIDefaultExceptionHandler implements APIExceptionHandler {
    /**
     * @description 예외를 처리하고 적절한 응답 생성
     * @param aEx 발생한 예외
     * @param aReq RestRequest 객체
     * @param aRes RestResponse 객체
     * @return APIProcessResult
     */
    public APIProcessResult handle(Exception aEx, RestRequest aReq, RestResponse aRes) {
        System.debug(LoggingLevel.ERROR, 'API Exception: ' + aEx.getMessage());
        System.debug(LoggingLevel.ERROR, 'Stack Trace: ' + aEx.getStackTraceString());

        Integer kStatusCode = 500;
        String kErrorType = aEx.getTypeName();

        // ScaffoldException statusCode 사용
        if (kErrorType == 'APIScaffold.ScaffoldException') {
            kStatusCode = ((APIScaffold.ScaffoldException) aEx).statusCode ?? kStatusCode;
        }

        APIResponse kResponse = new APIResponse.Builder()
                .success(false)
                .requestUrl(aReq.requestURI)
                .error(kErrorType, aEx.getMessage())
                .build();

        return new APIProcessResult(kStatusCode, kResponse).header(
                'Content-Type', 'application/json'
        );
    }
}
