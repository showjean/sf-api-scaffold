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
            APIScaffold kScaffold = APIScaffold.create()
                .route('/api/v1.0/*', new APIRouterV1())
                .route('/api/v2.0/*', new APIRouterV2())
                .exception(new DefaultExceptionHandler());

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
            APIScaffold kScaffold = APIScaffold.create()
                .route('/api/v1.0/*', new APIRouterV1())
                .route('/api/v2.0/*', new APIRouterV2())
                .exception(new DefaultExceptionHandler());

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
            APIScaffold kScaffold = APIScaffold.create()
                .route('/api/v1.0/*', new APIRouterV1())
                .exception(new DefaultExceptionHandler());

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
            APIScaffold kScaffold = APIScaffold.create()
                .route('/api/v1.0/*', new APIRouterV1());

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
            APIScaffold kScaffold = APIScaffold.create()
                .route('/api/v1.0/*', new APIRouterV1())
                .route('/api/v2.0/*', new APIRouterV2())
                .exception(new DefaultExceptionHandler());

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
            CompositeRouter kRouter = new CompositeRouter();
            kRouter.addProcessor('/api/v1.0/error', kErrorProcessor);

            APIScaffold kScaffold = APIScaffold.create()
                .route('/api/v1.0/*', kRouter)
                .exception(new DefaultExceptionHandler());

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
        public void process(RestRequest aReq, RestResponse aRes) {
            throw new CustomException('Test error');
        }
    }

    /**
     * @description 테스트용 커스텀 예외
     */
    private class CustomException extends Exception {
    }
}
