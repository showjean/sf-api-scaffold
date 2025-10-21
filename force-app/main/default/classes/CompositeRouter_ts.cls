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
            kRouter.addProcessor('/api/v1.0/health', new HealthCheckProcessor());

            // When
            APIProcessor kProcessor = kRouter.route('/api/v1.0/health');

            // Then
            Assert.isNotNull(kProcessor, 'Processor를 찾아야 함');
            Assert.isTrue(kProcessor instanceof HealthCheckProcessor, 'HealthCheckProcessor여야 함');
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
            kRouter.addProcessor('/api/users/*', new HealthCheckProcessor());

            // When
            APIProcessor kProcessor1 = kRouter.route('/api/users/123');
            APIProcessor kProcessor2 = kRouter.route('/api/users/abc/detail');

            // Then
            Assert.isNotNull(kProcessor1, '와일드카드 매칭이 되어야 함');
            Assert.isNotNull(kProcessor2, '와일드카드는 모든 하위 경로와 매칭되어야 함');
        }
    }

    /**
     * @description 파라미터(:id) 경로 매칭 테스트
     */
    @IsTest
    static void testParameterMatching() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given
            CompositeRouter kRouter = new CompositeRouter();
            kRouter.addProcessor('/api/users/:id', new HealthCheckProcessor());

            // When
            APIProcessor kProcessor = kRouter.route('/api/users/12345');

            // Then
            Assert.isNotNull(kProcessor, '파라미터 경로가 매칭되어야 함');
        }
    }

    /**
     * @description 파라미터 경로 매칭 실패 테스트
     */
    @IsTest
    static void testParameterMatchingFail() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given
            CompositeRouter kRouter = new CompositeRouter();
            kRouter.addProcessor('/api/users/:id', new HealthCheckProcessor());

            // When - 세그먼트 수가 다름
            APIProcessor kProcessor = kRouter.route('/api/users/123/detail');

            // Then
            Assert.isNull(kProcessor, '세그먼트 수가 다르면 매칭되지 않아야 함');
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
            kSubRouter.addProcessor('/api/users/list', new HealthCheckProcessor());

            // Given - 상위 라우터에 하위 라우터 등록
            CompositeRouter kMainRouter = new CompositeRouter();
            kMainRouter.addRouter('/api/users/*', kSubRouter);

            // When
            APIProcessor kProcessor = kMainRouter.route('/api/users/list');

            // Then
            Assert.isNotNull(kProcessor, '중첩된 라우터가 정상 작동해야 함');
            Assert.isTrue(kProcessor instanceof HealthCheckProcessor, 'HealthCheckProcessor여야 함');
        }
    }

    /**
     * @description 여러 경로 등록 및 우선순위 테스트
     */
    @IsTest
    static void testMultipleRoutePriority() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given - 먼저 등록된 경로가 우선
            CompositeRouter kRouter = new CompositeRouter();
            kRouter.addProcessor('/api/users/special', new HealthCheckProcessor());
            kRouter.addProcessor('/api/users/:id', new NotFoundProcessor());

            // When
            APIProcessor kProcessor = kRouter.route('/api/users/special');

            // Then
            Assert.isNotNull(kProcessor, 'Processor를 찾아야 함');
            Assert.isTrue(kProcessor instanceof HealthCheckProcessor, '먼저 등록된 경로가 매칭되어야 함');
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
            kRouter.addProcessor('/api/v1.0/health', new HealthCheckProcessor());

            // When
            APIProcessor kProcessor = kRouter.route('/api/v2.0/health');

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
                .addProcessor('/api/health', new HealthCheckProcessor())
                .addProcessor('/api/status', new NotFoundProcessor());

            // Then
            Assert.isNotNull(kRouter.route('/api/health'), '첫 번째 경로가 매칭되어야 함');
            Assert.isNotNull(kRouter.route('/api/status'), '두 번째 경로가 매칭되어야 함');
        }
    }

    /**
     * @description 복잡한 파라미터 경로 매칭 테스트
     */
    @IsTest
    static void testComplexParameterMatching() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given
            CompositeRouter kRouter = new CompositeRouter();
            kRouter.addProcessor('/api/:version/users/:id', new HealthCheckProcessor());

            // When
            APIProcessor kProcessor = kRouter.route('/api/v1/users/123');

            // Then
            Assert.isNotNull(kProcessor, '여러 파라미터가 있는 경로도 매칭되어야 함');
        }
    }
}
