/**
 * @description CompositeRouter 단위 테스트
 */
@IsTest
private class CompositeRouter_ts {

    /**
     * @description 단순 경로 매칭 테스트
     */
    @IsTest
    static void testSimpleRouteMatching() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given
            CompositeRouter kRouter = new CompositeRouter();
            kRouter.addProcessor('/api/v1.0/health', new TestHealthCheckProcessor());

            // When
            APIProcessor kProcessor = kRouter.route('', '/api/v1.0/health');

            // Then
            Assert.isNotNull(kProcessor, 'Processor를 찾아야 함');
            Assert.isTrue(kProcessor instanceof TestHealthCheckProcessor, 'TestHealthCheckProcessor여야 함');
        }
    }

    /**
     * @description 와일드카드 경로 매칭 테스트
     */
    @IsTest
    static void testWildcardMatching() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given
            CompositeRouter kRouter = new CompositeRouter();
            kRouter.addProcessor('/api/users/*', new TestHealthCheckProcessor());

            // When
            APIProcessor kProcessor1 = kRouter.route('', '/api/users/123');
            APIProcessor kProcessor2 = kRouter.route('', '/api/users/abc/detail');

            // Then
            Assert.isNotNull(kProcessor1, '와일드카드 매칭이 되어야 함');
            Assert.isNull(kProcessor2, '프로세서는 전체 경로와 일치해야 매칭');
        }
    }

    /**
     * @description Composite 패턴 - 중첩 라우터 테스트
     */
    @IsTest
    static void testNestedRouter() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given - 하위 라우터 생성
            CompositeRouter kSubRouter = new CompositeRouter();
            kSubRouter.addProcessor('/list', new TestHealthCheckProcessor());

            // Given - 상위 라우터에 하위 라우터 등록
            CompositeRouter kMainRouter = new CompositeRouter();
            kMainRouter.addRouter('/api/users/*', kSubRouter);

            // When
            APIProcessor kProcessor = kMainRouter.route('', '/api/users/list');

            // Then
            Assert.isNotNull(kProcessor, '중첩된 라우터가 정상 작동해야 함');
            Assert.isTrue(kProcessor instanceof TestHealthCheckProcessor, 'TestHealthCheckProcessor여야 함');
        }
    }

    /**
     * @description 여러 경로 등록 및 우선순위 테스트
     */
    @IsTest
    static void testMultipleRoutePriority() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given - 먼저 등록된 정확한 경로가 와일드카드보다 우선
            CompositeRouter kRouter = new CompositeRouter();
            kRouter.addProcessor('/api/users/special', new TestHealthCheckProcessor());
            kRouter.addProcessor('/api/users/*', new NotFoundProcessor());

            // When
            APIProcessor kProcessor = kRouter.route('', '/api/users/special');

            // Then
            Assert.isNotNull(kProcessor, 'Processor를 찾아야 함');
            Assert.isTrue(kProcessor instanceof TestHealthCheckProcessor, '정확한 경로가 먼저 매칭되어야 함');
        }
    }

    /**
     * @description 매칭되는 경로가 없는 경우 테스트
     */
    @IsTest
    static void testNoMatchingRoute() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given
            CompositeRouter kRouter = new CompositeRouter();
            kRouter.addProcessor('/api/v1.0/health', new TestHealthCheckProcessor());

            // When
            APIProcessor kProcessor = kRouter.route('', '/api/v2.0/health');

            // Then
            Assert.isNull(kProcessor, '매칭되는 경로가 없으면 null을 반환해야 함');
        }
    }

    /**
     * @description 체이닝 메서드 테스트
     */
    @IsTest
    static void testMethodChaining() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given & When - 체이닝으로 여러 경로 등록
            CompositeRouter kRouter = new CompositeRouter()
                .addProcessor('/api/health', new TestHealthCheckProcessor())
                .addProcessor('/api/status', new NotFoundProcessor());

            // Then
            Assert.isNotNull(kRouter.route('', '/api/health'), '첫 번째 경로가 매칭되어야 함');
            Assert.isNotNull(kRouter.route('', '/api/status'), '두 번째 경로가 매칭되어야 함');
        }
    }

    /**
     * @description 중간 와일드카드 매칭 테스트
     */
    @IsTest
    static void testMiddleWildcardMatching() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given
            CompositeRouter kRouter = new CompositeRouter();
            kRouter.addProcessor('/api/v1.0/*/view', new TestHealthCheckProcessor());

            // When
            APIProcessor kProcessor1 = kRouter.route('', '/api/v1.0/users/view');
            APIProcessor kProcessor2 = kRouter.route('', '/api/v1.0/orders/view');
            APIProcessor kProcessor3 = kRouter.route('', '/api/v1.0/products/view');

            // Then
            Assert.isNotNull(kProcessor1, '중간 와일드카드 매칭 - users');
            Assert.isNotNull(kProcessor2, '중간 와일드카드 매칭 - orders');
            Assert.isNotNull(kProcessor3, '중간 와일드카드 매칭 - products');
        }
    }

    /**
     * @description 중간 와일드카드 매칭 실패 테스트 - 세그먼트 개수 불일치
     */
    @IsTest
    static void testMiddleWildcardMatchingFail() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given
            CompositeRouter kRouter = new CompositeRouter();
            kRouter.addProcessor('/api/v1.0/*/view', new TestHealthCheckProcessor());

            // When - 세그먼트 개수가 다름
            APIProcessor kProcessor1 = kRouter.route('', '/api/v1.0/users');
            APIProcessor kProcessor2 = kRouter.route('', '/api/v1.0/users/123/view');
            APIProcessor kProcessor3 = kRouter.route('', '/api/v1.0/users/edit');

            // Then
            Assert.isNull(kProcessor1, '세그먼트 개수 부족');
            Assert.isNull(kProcessor2, '세그먼트 개수 초과');
            Assert.isNull(kProcessor3, '마지막 세그먼트 불일치');
        }
    }

    /**
     * @description 여러 와일드카드 매칭 테스트
     */
    @IsTest
    static void testMultipleWildcards() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given
            CompositeRouter kRouter = new CompositeRouter();
            kRouter.addProcessor('/api/*/users/*/view', new TestHealthCheckProcessor());

            // When
            APIProcessor kProcessor = kRouter.route('', '/api/v1/users/123/view');

            // Then
            Assert.isNotNull(kProcessor, '여러 와일드카드 매칭');
        }
    }

    /**
     * @description 끝 vs 중간 와일드카드 구분 테스트
     */
    @IsTest
    static void testEndVsMiddleWildcard() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given
            CompositeRouter kRouter = new CompositeRouter();
            kRouter.addProcessor('/api/users/*', new TestHealthCheckProcessor());     // 끝 와일드카드
            kRouter.addProcessor('/api/orders/*/view', new NotFoundProcessor()); // 중간 와일드카드

            // When - 끝 와일드카드는 모든 하위 경로 매칭
            APIProcessor kProcessor1 = kRouter.route('', '/api/users/123');
            APIProcessor kProcessor2 = kRouter.route('', '/api/users/123/detail');
            APIProcessor kProcessor3 = kRouter.route('', '/api/users/123/detail/info');

            // Then
            Assert.isNotNull(kProcessor1, '끝 와일드카드 - 1단계');
            Assert.isNull(kProcessor2, '끝 와일드카드 - 2단계 - 프로세서 최종 경로 불일치');
            Assert.isNull(kProcessor3, '끝 와일드카드 - 3단계 - 프로세서 최종 경로 불일치');

            // When - 중간 와일드카드는 정확한 세그먼트 개수만 매칭
            APIProcessor kProcessor4 = kRouter.route('', '/api/orders/123/view');
            APIProcessor kProcessor5 = kRouter.route('', '/api/orders/123');
            APIProcessor kProcessor6 = kRouter.route('', '/api/orders/123/view/detail');

            // Then
            Assert.isNotNull(kProcessor4, '중간 와일드카드 - 정확한 매칭');
            Assert.isNull(kProcessor5, '중간 와일드카드 - 세그먼트 부족');
            Assert.isNull(kProcessor6, '중간 와일드카드 - 세그먼트 초과');
        }
    }
    
    /**
     * @description 상대 경로 처리 테스트 - Router 재사용
     */
    @IsTest
    static void testRelativePathRouting() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given - 상대 경로로 등록된 하위 라우터
            CompositeRouter kSubRouter = new CompositeRouter();
            kSubRouter.addProcessor('/health', new TestHealthCheckProcessor());
            kSubRouter.addProcessor('/status', new TestHealthCheckProcessor());

            // When - 절대 경로로 요청
            APIProcessor kProcessor1 = kSubRouter.route('/api/v1.0', '/api/v1.0/health');
            APIProcessor kProcessor2 = kSubRouter.route('/api/v1.0', '/api/v1.0/status');

            // Then
            Assert.isNotNull(kProcessor1, 'prefix가 제거된 상대 경로로 매칭되어야 함');
            Assert.isNotNull(kProcessor2, '다른 상대 경로도 매칭되어야 함');
        }
    }

    /**
     * @description Router 재사용 테스트 - 같은 라우터를 다른 prefix에 등록
     */
    @IsTest
    static void testRouterReusability() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given - 재사용 가능한 라우터 (상대 경로로 등록)
            CompositeRouter kReusableRouter = new CompositeRouter();
            kReusableRouter.addProcessor('/health', new TestHealthCheckProcessor());

            // Given - v1.0과 v2.0에 같은 라우터 사용
            CompositeRouter kV1Router = new CompositeRouter();
            kV1Router.addRouter('/sub/*', kReusableRouter);

            CompositeRouter kV2Router = new CompositeRouter();
            kV2Router.addRouter('/sub/*', kReusableRouter);

            // When
            APIProcessor kV1Processor = kV1Router.route('/api/v1.0', '/api/v1.0/sub/health');
            APIProcessor kV2Processor = kV2Router.route('/api/v2.0', '/api/v2.0/sub/health');

            // Then - 같은 라우터가 다른 경로에서 재사용됨
            Assert.isNotNull(kV1Processor, 'v1.0 경로에서 작동해야 함');
            Assert.isNotNull(kV2Processor, 'v2.0 경로에서 작동해야 함');
        }
    }

    /**
     * @description Prefix 없는 라우터 동작 테스트 (하위 호환성)
     */
    @IsTest
    static void testNoPrefix() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given - prefix 없이 생성 (기존 방식)
            CompositeRouter kRouter = new CompositeRouter();
            kRouter.addProcessor('/api/health', new TestHealthCheckProcessor());

            // When
            APIProcessor kProcessor = kRouter.route('', '/api/health');

            // Then
            Assert.isNotNull(kProcessor, 'prefix 없이도 정상 작동해야 함');
        }
    }

    /**
     * @description 중첩된 상대 경로 테스트
     */
    @IsTest
    static void testNestedRelativePath() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given - 3단계 중첩 라우터
            CompositeRouter kLeafRouter = new CompositeRouter();
            kLeafRouter.addProcessor('/view', new TestHealthCheckProcessor());

            CompositeRouter kMiddleRouter = new CompositeRouter();
            kMiddleRouter.addRouter('/users/*', kLeafRouter);

            CompositeRouter kRootRouter = new CompositeRouter();
            kRootRouter.addRouter('/api/v1.0/*', kMiddleRouter);

            // When - 절대 경로 요청
            APIProcessor kProcessor = kRootRouter.route('', '/api/v1.0/users/view');

            // Then
            Assert.isNotNull(kProcessor, '중첩된 상대 경로가 정상 작동해야 함');
        }
    }

    /**
     * @description Trailing slash 정규화 테스트
     */
    @IsTest
    static void testTrailingSlashNormalization() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given
            CompositeRouter kRouter = new CompositeRouter();
            kRouter.addProcessor('/api/users', new TestHealthCheckProcessor());

            // When - trailing slash 있는 경로로 요청
            APIProcessor kProcessor1 = kRouter.route('', '/api/users');
            APIProcessor kProcessor2 = kRouter.route('', '/api/users/');

            // Then - 둘 다 매칭되어야 함
            Assert.isNotNull(kProcessor1, 'trailing slash 없는 경로 매칭');
            Assert.isNotNull(kProcessor2, 'trailing slash 있는 경로도 동일하게 매칭');
        }
    }

    /**
     * @description 루트 경로 정규화 테스트
     */
    @IsTest
    static void testRootPathNormalization() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given
            CompositeRouter kRouter = new CompositeRouter();
            kRouter.addProcessor('/', new TestHealthCheckProcessor());

            // When
            APIProcessor kProcessor1 = kRouter.route('', '/');
            APIProcessor kProcessor2 = kRouter.route('', '');

            // Then
            Assert.isNotNull(kProcessor1, '루트 경로 / 매칭');
            Assert.isNotNull(kProcessor2, '빈 문자열도 루트 경로로 매칭');
        }
    }

    /**
     * @description 패턴에 trailing slash가 있는 경우 테스트
     */
    @IsTest
    static void testPatternWithTrailingSlash() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given - 패턴에 trailing slash
            CompositeRouter kRouter = new CompositeRouter();
            kRouter.addProcessor('/api/users/', new TestHealthCheckProcessor());

            // When
            APIProcessor kProcessor1 = kRouter.route('', '/api/users');
            APIProcessor kProcessor2 = kRouter.route('', '/api/users/');

            // Then - 둘 다 매칭
            Assert.isNotNull(kProcessor1, '패턴에 trailing slash 있어도 없는 경로와 매칭');
            Assert.isNotNull(kProcessor2, '패턴에 trailing slash 있고 경로에도 있으면 매칭');
        }
    }

    class TestHealthCheckProcessor implements APIProcessor {
        /**
         * @description 헬스 체크 요청 처리
         * @param aReq RestRequest 객체
         * @param aRes RestResponse 객체
         */
        public void process(RestRequest aReq, RestResponse aRes) {
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

    class TestAPIRouterV1 implements APIRouter {
        private CompositeRouter compositeRouter;

        /**
         * @description 생성자 - 라우트 초기화
         */
        public TestAPIRouterV1() {
            this.compositeRouter = new CompositeRouter();
            this.initializeRoutes();
        }

        /**
         * @description 라우트 초기화
         */
        private void initializeRoutes() {
            // 헬스 체크 엔드포인트
            this.compositeRouter.addProcessor('/', new TestHealthCheckProcessor());

            // 추가 라우트는 여기에 등록
            // this.compositeRouter.addProcessor('/users', new UserListProcessor());
            // this.compositeRouter.addRouter('/users/*', new UserRouter());
        }

        /**
         * @description APIRouter 인터페이스 구현
         * @param aPrevPath 지나온 경로
         * @param aPath 요청 경로
         * @return 매칭된 APIProcessor
         */
        public APIProcessor route(String aPrevPath, String aPath) {
            return this.compositeRouter.route(aPrevPath, aPath);
        }
    }
}
