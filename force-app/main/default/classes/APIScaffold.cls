/**
 * @description Rest API 요청을 적절한 Router와 Processor로 라우팅하는 Scaffold 클래스 (Builder 패턴)
 * Created by hyodongmin on 2025. 10. 21.
 */
public class APIScaffold {
    private CompositeRouter router;
    private APIExceptionHandler exceptionHandler;

    /**
     * @description 기본 생성자 (private)
     */
    private APIScaffold() {
        this.router = new CompositeRouter('');
    }

    /**
     * @description Builder 패턴 시작
     * @return APIScaffold 인스턴스 (체이닝용)
     */
    public static APIScaffold create() {
        APIScaffold kScaffold = new APIScaffold();
        return kScaffold;
    }

    /**
     * @description 경로 등록 (체이닝)
     * @param aPattern 경로 패턴 (예: '/api/v1.0/*')
     * @param aRouter APIRouter 구현체
     * @return APIScaffold 인스턴스 (체이닝용)
     */
    public APIScaffold route(String aPattern, APIRouter aRouter) {
        this.router.addRouter(aPattern, aRouter);
        return this;
    }

    /**
     * @description 예외 핸들러 설정
     * @param aHandler APIExceptionHandler 구현체
     * @return APIScaffold 인스턴스 (체이닝용)
     */
    public APIScaffold exception(APIExceptionHandler aHandler) {
        this.exceptionHandler = aHandler;
        return this;
    }

    /**
     * @description Rest API 요청 처리
     * @param aReq RestRequest 객체
     * @param aRes RestResponse 객체
     */
    public void process(RestRequest aReq, RestResponse aRes) {
        try {
            String kPath = aReq.requestURI;
            System.debug(LoggingLevel.INFO, '⭐️requestURI: ' + kPath);
            APIProcessor kProcessor = this.router.route(kPath);

            if (kProcessor != null) {
                System.debug(LoggingLevel.INFO, '✅Processor -> ' + kProcessor.toString().substringBefore(':'));
                kProcessor.process(aReq, aRes);
            }
            else {
                // 매칭되는 경로가 없는 경우
                throw new RouteNotFoundException('No matching route found for: ' + kPath);
            }
        }
        catch (Exception kEx) {
            this.handleException(kEx, aRes);
        }
    }

    /**
     * @description 예외 처리
     * @param aEx 발생한 예외
     * @param aRes RestResponse 객체
     */
    private void handleException(Exception aEx, RestResponse aRes) {
        if (this.exceptionHandler != null) {
            this.exceptionHandler.handle(aEx, aRes);
        }
        else {
            // 기본 예외 처리
            aRes.statusCode = 500;
            Map<String, String> kErrorBody = new Map<String, String>{
                'error' => aEx.getMessage(),
                'type' => aEx.getTypeName()
            };
            aRes.responseBody = Blob.valueOf(JSON.serialize(kErrorBody));
        }
    }

    /**
     * @description 경로를 찾을 수 없을 때 발생하는 예외
     */
    public class RouteNotFoundException extends Exception {
    }
}