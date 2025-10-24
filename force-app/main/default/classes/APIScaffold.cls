/**
 * @description Rest API 요청을 적절한 Router와 Processor로 라우팅하는 Scaffold 클래스 (Builder 패턴)
 * Created by hyodongmin on 2025. 10. 21.
 */
public class APIScaffold {
    private final APICompositeRouter router;
    private APIExceptionHandler exceptionHandler;
    private final String mainPath;

    /**
     * @description 기본 생성자 (private)
     * @param aMainPath Rest API 시작 path
     */
    private APIScaffold(String aMainPath) {
        this.router = new APICompositeRouter();
        this.mainPath = true == aMainPath?.endsWith('/*') ? aMainPath.substringBeforeLast('/*') : aMainPath;
    }

    /**
     * @description Builder 패턴 시작
     * @param aMainPath Rest API 시작 path, Rest 설정 경로가 `@RestResource(UrlMapping='/api/*')` 라면 '/api' 를 입력한다.
     * @return APIScaffold 인스턴스 (체이닝용)
     */
    public static APIScaffold create(String aMainPath) {
        APIScaffold kScaffold = new APIScaffold(aMainPath);
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
     * @description 경로 등록 (체이닝)
     * @param aPattern 경로 패턴 (예: '/api/v1.0/*')
     * @param aHttpMethod Http Method
     * @param aRouter APIRouter 구현체
     * @return APIScaffold 인스턴스 (체이닝용)
     */
    public APIScaffold route(String aPattern, String aHttpMethod, APIRouter aRouter) {
        this.router.addRouter(aPattern, aHttpMethod, aRouter);
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
            System.debug(LoggingLevel.INFO, '⭐️Main path: ' + this.mainPath + ', requestURI: ' + kPath);

            APIContext kContext = new APIContext.Builder()
                .pattern('')
                .requestUrl(kPath)
                .httpMethod(aReq.httpMethod)
                .processor(null)
                .build();

            kContext = this.router.route(kContext, this.mainPath, kPath);
            APIProcessor kProcessor = kContext.processor;

            if (kProcessor != null) {
                System.debug(LoggingLevel.INFO, '✅Processor -> ' + kProcessor.toString().substringBefore(':'));
                System.debug(LoggingLevel.INFO, 'Context -> ' + kContext);
                kProcessor.process(kContext, aReq, aRes);
            }
            else {
                // 매칭되는 경로가 없는 경우
                throw new ScaffoldException('No matching route found for: ' + kPath).statusCode(404);
            }
        }
        catch (Exception kEx) {
            this.handleException(kEx, aReq, aRes);
        }
    }

    /**
     * @description 예외 처리
     * @param aEx 발생한 예외
     * @param aReq RestRequest 객체
     * @param aRes RestResponse 객체
     */
    private void handleException(Exception aEx,  RestRequest aReq, RestResponse aRes) {
        if (this.exceptionHandler != null) {
            this.exceptionHandler.handle(aEx, aReq, aRes);
        }
        else {
            // 기본 예외 처리
            aRes.statusCode = 500;
            APIResponse kResponse = new APIResponse.Builder()
                    .success(false)
                    .error(aEx.getTypeName(), aEx.getMessage())
                    .requestUrl(aReq.requestURI)
                    .build();
            aRes.responseBody = Blob.valueOf(JSON.serialize(kResponse));
        }
    }

    /**
     * @description 경로를 찾을 수 없을 때 발생하는 예외
     */
    public class ScaffoldException extends Exception {
        public Integer statusCode {get; private set;}

        public ScaffoldException statusCode(Integer aStatusCode) {
            this.statusCode = aStatusCode;
            return this;
        }
    }
}