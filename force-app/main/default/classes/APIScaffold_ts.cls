/**
 * @description APIScaffold 단위 테스트
 */
@IsTest
private class APIScaffold_ts {

    /**
     * @description 성공적인 라우팅 테스트
     */
    @IsTest
    static void testSuccessfulRouting() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given - Scaffold 설정
            APIScaffold kScaffold = APIScaffold.create('')
                .route('/api/v1.0/*', new TestAPIRouterV1())
                .route('/api/v2.0/*', new TestAPIRouterV2())
                .exception(new APIDefaultExceptionHandler());

            // Given - Mock Request/Response
            RestRequest kReq = new RestRequest();
            kReq.requestURI = '/api/v1.0/health';
            kReq.httpMethod = 'GET';

            RestResponse kRes = new RestResponse();

            // When
            kScaffold.process(kReq, kRes);

            // Then
            Assert.areEqual(200, kRes.statusCode, 'Status code는 200이어야 함');
            Assert.isNotNull(kRes.responseBody, 'Response body는 null이 아니어야 함');

            String kResponseBody = kRes.responseBody.toString();
            Assert.isTrue(kResponseBody.contains('healthy'), 'Response에 healthy가 포함되어야 함');
        }
    }

    /**
     * @description V2 라우팅 테스트
     */
    @IsTest
    static void testV2Routing() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given
            APIScaffold kScaffold = APIScaffold.create('')
                .route('/api/v1.0/*', new TestAPIRouterV1())
                .route('/api/v2.0/*', new TestAPIRouterV2())
                .exception(new APIDefaultExceptionHandler());

            RestRequest kReq = new RestRequest();
            kReq.requestURI = '/api/v2.0/health';
            kReq.httpMethod = 'GET';

            RestResponse kRes = new RestResponse();

            // When
            kScaffold.process(kReq, kRes);

            // Then
            Assert.areEqual(200, kRes.statusCode, 'V2 라우팅도 정상 동작해야 함');
        }
    }

    /**
     * @description 경로를 찾을 수 없는 경우 테스트
     */
    @IsTest
    static void testRouteNotFound() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given
            APIScaffold kScaffold = APIScaffold.create('')
                .route('/api/v1.0/*', new TestAPIRouterV1())
                .exception(new APIDefaultExceptionHandler());

            RestRequest kReq = new RestRequest();
            kReq.requestURI = '/api/v1.0/nonexistent';
            kReq.httpMethod = 'GET';

            RestResponse kRes = new RestResponse();

            // When
            kScaffold.process(kReq, kRes);

            // Then
            Assert.areEqual(404, kRes.statusCode, '존재하지 않는 경로는 404를 반환해야 함');
        }
    }

    /**
     * @description 예외 핸들러 없이 404 처리 테스트
     */
    @IsTest
    static void testRouteNotFoundWithoutExceptionHandler() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given - 예외 핸들러 없음
            APIScaffold kScaffold = APIScaffold.create('')
                .route('/api/v1.0/*', new TestAPIRouterV1());

            RestRequest kReq = new RestRequest();
            kReq.requestURI = '/api/v1.0/nonexistent';
            kReq.httpMethod = 'GET';

            RestResponse kRes = new RestResponse();

            // When
            kScaffold.process(kReq, kRes);

            // Then - 기본 예외 처리로 500 반환
            Assert.areEqual(500, kRes.statusCode, '기본 예외 처리는 500을 반환해야 함');
            Assert.isNotNull(kRes.responseBody, 'Error response body가 있어야 함');
        }
    }

    /**
     * @description 여러 경로 등록 테스트
     */
    @IsTest
    static void testMultipleRoutes() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given
            APIScaffold kScaffold = APIScaffold.create('')
                .route('/api/v1.0/*', new TestAPIRouterV1())
                .route('/api/v2.0/*', new TestAPIRouterV2())
                .exception(new APIDefaultExceptionHandler());

            // When & Then - V1 테스트
            RestRequest kReqV1 = new RestRequest();
            kReqV1.requestURI = '/api/v1.0/health';
            RestResponse kResV1 = new RestResponse();

            kScaffold.process(kReqV1, kResV1);
            Assert.areEqual(200, kResV1.statusCode, 'V1 경로가 정상 작동해야 함');

            // When & Then - V2 테스트
            RestRequest kReqV2 = new RestRequest();
            kReqV2.requestURI = '/api/v2.0/health';
            RestResponse kResV2 = new RestResponse();

            kScaffold.process(kReqV2, kResV2);
            Assert.areEqual(200, kResV2.statusCode, 'V2 경로가 정상 작동해야 함');
        }
    }

    /**
     * @description Processor에서 예외 발생 시 테스트
     */
    @IsTest
    static void testProcessorException() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given - 예외를 던지는 Mock Processor
            MockErrorProcessor kErrorProcessor = new MockErrorProcessor();
            APICompositeRouter kRouter = new APICompositeRouter();
            kRouter.addProcessor('/error', kErrorProcessor);

            APIScaffold kScaffold = APIScaffold.create('')
                .route('/api/v1.0/*', kRouter)
                .exception(new APIDefaultExceptionHandler());

            RestRequest kReq = new RestRequest();
            kReq.requestURI = '/api/v1.0/error';
            RestResponse kRes = new RestResponse();

            // When
            kScaffold.process(kReq, kRes);

            // Then
            Assert.areEqual(500, kRes.statusCode, '예외 발생 시 500을 반환해야 함');
            String kResponseBody = kRes.responseBody.toString();
            Assert.isTrue(kResponseBody.contains('Test error'), '에러 메시지가 포함되어야 함');
        }
    }

    /**
     * @description Mock Processor - 에러를 발생시킴
     */
    private class MockErrorProcessor implements APIProcessor {
        public void process(APIContext aContext, RestRequest aReq, RestResponse aRes) {
            throw new CustomException('Test error');
        }
    }

    /**
     * @description 테스트용 커스텀 예외
     */
    private class CustomException extends Exception {
    }

    class TestAPIRouterV1 implements APIRouter {
        private APICompositeRouter compositeRouter;

        /**
         * @description 생성자 - 라우트 초기화
         */
        public TestAPIRouterV1() {
            this.compositeRouter = new APICompositeRouter();
            this.initializeRoutes();
        }

        /**
         * @description 라우트 초기화
         */
        private void initializeRoutes() {
            // 헬스 체크 엔드포인트
            this.compositeRouter.addProcessor('/health', new TestHealthCheckProcessor());

            // 추가 라우트는 여기에 등록
            // this.compositeRouter.addProcessor('/users', new UserListProcessor());
            // this.compositeRouter.addRouter('/users/*', new UserRouter());
        }

        /**
         * @description APIRouter 인터페이스 구현
         * @param aContext APIContext 객체
         * @param aPrevPath 지나온 경로
         * @param aPath 요청 경로
         * @return 매칭 결과 APIContext, 매칭 Processor가 없으면 APIContext.processor = null 로 반환
         */
        public APIContext route(APIContext aContext, String aPrevPath, String aPath) {
            return this.compositeRouter.route(aContext, aPrevPath, aPath);
        }
    }

    class TestAPIRouterV2 implements APIRouter {
        private APICompositeRouter compositeRouter;

        /**
         * @description 생성자 - 라우트 초기화
         */
        public TestAPIRouterV2() {
            this.compositeRouter = new APICompositeRouter();
            this.initializeRoutes();
        }

        /**
         * @description 라우트 초기화
         */
        private void initializeRoutes() {
            // v2.0용 헬스 체크
            this.compositeRouter.addProcessor('/health', new TestHealthCheckProcessor());

            // v2.0 추가 라우트
            // this.compositeRouter.addProcessor('/status', new StatusProcessor());
        }

        /**
         * @description APIRouter 인터페이스 구현
         * @param aContext APIContext 객체
         * @param aPrevPath 지나온 경로
         * @param aPath 요청 경로
         * @return 매칭 결과 APIContext, 매칭 Processor가 없으면 APIContext.processor = null 로 반환
         */
        public APIContext route(APIContext aContext, String aPrevPath, String aPath) {
            return this.compositeRouter.route(aContext, aPrevPath, aPath);
        }
    }
    
    /**
     * @description MainPath 라우팅 테스트
     */
    @IsTest
    static void testMainPathRouting() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given - mainPath를 '/services/apexrest'로 설정
            APICompositeRouter kRouter = new APICompositeRouter();
            kRouter.addProcessor('/health', new TestHealthCheckProcessor());

            APIScaffold kScaffold = APIScaffold.create('/services/apexrest')
                .route('/api/v1.0/*', kRouter)
                .exception(new APIDefaultExceptionHandler());

            // When
            RestRequest kReq = new RestRequest();
            kReq.requestURI = '/services/apexrest/api/v1.0/health';
            kReq.httpMethod = 'GET';
            RestResponse kRes = new RestResponse();

            kScaffold.process(kReq, kRes);

            // Then
            Assert.areEqual(200, kRes.statusCode, 'mainPath가 적용된 경로가 정상 작동해야 함');
        }
    }

    /**
     * @description HTTP 메서드 기반 라우팅 테스트
     */
    @IsTest
    static void testHttpMethodRouting() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given
            APICompositeRouter kGetRouter = new APICompositeRouter();
            kGetRouter.addProcessor('/users', new GetUsersProcessor());

            APICompositeRouter kPostRouter = new APICompositeRouter();
            kPostRouter.addProcessor('/users', new CreateUserProcessor());

            APIScaffold kScaffold = APIScaffold.create('')
                .route('/api/v1.0/*', 'GET', kGetRouter)
                .route('/api/v1.0/*', 'POST', kPostRouter)
                .exception(new APIDefaultExceptionHandler());

            // When - GET 요청
            RestRequest kGetReq = new RestRequest();
            kGetReq.requestURI = '/api/v1.0/users';
            kGetReq.httpMethod = 'GET';
            RestResponse kGetRes = new RestResponse();

            kScaffold.process(kGetReq, kGetRes);

            // Then
            Assert.areEqual(200, kGetRes.statusCode, 'GET 요청이 정상 처리되어야 함');
            String kGetResponseBody = kGetRes.responseBody.toString();
            Assert.isTrue(kGetResponseBody.contains('users'), 'GET response에 users가 포함되어야 함');

            // When - POST 요청
            RestRequest kPostReq = new RestRequest();
            kPostReq.requestURI = '/api/v1.0/users';
            kPostReq.httpMethod = 'POST';
            RestResponse kPostRes = new RestResponse();

            kScaffold.process(kPostReq, kPostRes);

            // Then
            Assert.areEqual(201, kPostRes.statusCode, 'POST 요청이 정상 처리되어야 함');
            String kPostResponseBody = kPostRes.responseBody.toString();
            Assert.isTrue(kPostResponseBody.contains('created'), 'POST response에 created가 포함되어야 함');
        }
    }

    /**
     * @description APIContext 전파 테스트
     */
    @IsTest
    static void testContextPropagation() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given
            ContextCheckProcessor kProcessor = new ContextCheckProcessor();
            APICompositeRouter kRouter = new APICompositeRouter();
            kRouter.addProcessor('/:userId/profile', kProcessor);

            APIScaffold kScaffold = APIScaffold.create('')
                .route('/api/users/*', kRouter)
                .exception(new APIDefaultExceptionHandler());

            // When
            RestRequest kReq = new RestRequest();
            kReq.requestURI = '/api/users/123/profile';
            kReq.httpMethod = 'GET';
            RestResponse kRes = new RestResponse();

            kScaffold.process(kReq, kRes);

            // Then
            Assert.areEqual(200, kRes.statusCode, '요청이 정상 처리되어야 함');
            Assert.isNotNull(kProcessor.receivedContext, 'Processor가 Context를 받아야 함');
            Assert.areEqual('GET', kProcessor.receivedContext.httpMethod, 'httpMethod가 전파되어야 함');
            Assert.areEqual('/api/users/123/profile', kProcessor.receivedContext.requestUrl, 'requestUrl이 전파되어야 함');
            Assert.isNotNull(kProcessor.receivedContext.pathVar, 'pathVar가 설정되어야 함');
            Assert.areEqual('123', kProcessor.receivedContext.pathVar.get('userId'), 'userId가 파싱되어야 함');
        }
    }

    /**
     * @description HTTP 메서드 불일치로 인한 404 테스트
     */
    @IsTest
    static void testHttpMethodMismatch() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given - GET만 허용
            APICompositeRouter kRouter = new APICompositeRouter();
            kRouter.addProcessor('/users', 'GET', new GetUsersProcessor());

            APIScaffold kScaffold = APIScaffold.create('')
                .route('/api/v1.0/*', kRouter)
                .exception(new APIDefaultExceptionHandler());

            // When - POST 요청
            RestRequest kReq = new RestRequest();
            kReq.requestURI = '/api/v1.0/users';
            kReq.httpMethod = 'POST';
            RestResponse kRes = new RestResponse();

            kScaffold.process(kReq, kRes);

            // Then
            Assert.areEqual(404, kRes.statusCode, 'HTTP 메서드가 맞지 않으면 404를 반환해야 함');
        }
    }

    class TestHealthCheckProcessor implements APIProcessor {
        /**
         * @description 헬스 체크 요청 처리
         * @param aContext APIContext 객체
         * @param aReq RestRequest 객체
         * @param aRes RestResponse 객체
         */
        public void process(APIContext aContext, RestRequest aReq, RestResponse aRes) {
            Map<String, Object> kResponse = new Map<String, Object>{
                    'status' => 'healthy',
                    'timestamp' => Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''),
                    'version' => '1.0.0'
            };

            aRes.statusCode = 200;
            aRes.responseBody = Blob.valueOf(JSON.serialize(kResponse));
            aRes.addHeader('Content-Type', 'application/json');
        }
    }

    class GetUsersProcessor implements APIProcessor {
        public void process(APIContext aContext, RestRequest aReq, RestResponse aRes) {
            Map<String, Object> kResponse = new Map<String, Object>{
                'users' => new List<String>{'user1', 'user2'}
            };
            aRes.statusCode = 200;
            aRes.responseBody = Blob.valueOf(JSON.serialize(kResponse));
            aRes.addHeader('Content-Type', 'application/json');
        }
    }

    class CreateUserProcessor implements APIProcessor {
        public void process(APIContext aContext, RestRequest aReq, RestResponse aRes) {
            Map<String, Object> kResponse = new Map<String, Object>{
                'message' => 'User created',
                'userId' => '123'
            };
            aRes.statusCode = 201;
            aRes.responseBody = Blob.valueOf(JSON.serialize(kResponse));
            aRes.addHeader('Content-Type', 'application/json');
        }
    }

    class ContextCheckProcessor implements APIProcessor {
        public APIContext receivedContext;

        public void process(APIContext aContext, RestRequest aReq, RestResponse aRes) {
            this.receivedContext = aContext;
            aRes.statusCode = 200;
            aRes.responseBody = Blob.valueOf('OK');
        }
    }

}
