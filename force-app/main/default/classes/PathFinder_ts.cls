/**
 * @description PathFinder 단위 테스트
 */
@IsTest
private class PathFinder_ts {

    /**
     * @description 기본 경로 매칭 테스트
     */
    @IsTest
    static void testBasicPathMatching() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given
            PathFinder kFinder = new PathFinder('', '/users');

            // When & Then
            Assert.isTrue(kFinder.find('/users'), '전체 경로가 일치해야 함');
            Assert.isFalse(kFinder.find('/profile'), '다른 경로는 불일치');
        }
    }

    /**
     * @description 계층 구조 경로 매칭 테스트
     */
    @IsTest
    static void testHierarchicalPathMatching() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given - PrevPath: '/api/v1.0', OriginPath: '/api/v1.0/users/profile'
            PathFinder kFinder = new PathFinder('/api/v1.0', '/api/v1.0/users/profile');

            // When & Then - PrevPath + NextPath가 OriginPath의 앞부분과 일치하거나 정확히 일치
            Assert.isTrue(kFinder.find('/users/profile'), '/users/profile이 정확히 일치');
            Assert.isTrue(kFinder.find('/users'), '/users는 앞부분 일치');
            Assert.isFalse(kFinder.find('/profile'), '/profile은 불일치');
        }
    }

    /**
     * @description 복잡한 계층 구조 테스트
     */
    @IsTest
    static void testComplexHierarchy() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given - PrevPath: '/api/v1.0/users/123', OriginPath: '/api/v1.0/users/123/view'
            PathFinder kFinder = new PathFinder('/api/v1.0/users/123', '/api/v1.0/users/123/view');

            // When & Then
            Assert.isTrue(kFinder.find('/view'), '/view가 일치해야 함');
            Assert.isFalse(kFinder.find('/edit'), '/edit는 불일치');
        }
    }

    /**
     * @description Trailing slash 정규화 테스트
     */
    @IsTest
    static void testTrailingSlashNormalization() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given
            PathFinder kFinder = new PathFinder('/api', '/api/users');

            // When & Then - trailing slash 있어도 동일하게 처리
            Assert.isTrue(kFinder.find('/users'), 'trailing slash 없는 경로 매칭');
            Assert.isTrue(kFinder.find('/users/'), 'trailing slash 있는 경로도 동일하게 매칭');
        }
    }

    /**
     * @description 루트 경로 테스트
     */
    @IsTest
    static void testRootPath() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given
            PathFinder kFinder1 = new PathFinder('', '/');
            PathFinder kFinder2 = new PathFinder('/', '/users');

            // When & Then
            Assert.isTrue(kFinder1.find('/'), '루트 경로 / 매칭');
            Assert.isTrue(kFinder1.find(''), '빈 문자열도 루트 경로로 매칭');
            Assert.isTrue(kFinder2.find('/users'), '/users 매칭');
        }
    }

    /**
     * @description PrevPath가 비어있는 경우 테스트
     */
    @IsTest
    static void testEmptyPrevPath() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given - PrevPath가 비어있음
            PathFinder kFinder = new PathFinder('', '/api/users/profile');

            // When & Then
            Assert.isTrue(kFinder.find('/api/users/profile'), '전체 경로가 정확히 일치');
            Assert.isTrue(kFinder.find('/api/users'), '부분 경로는 앞부분 일치');
            Assert.isTrue(kFinder.find('/api'), '더 짧은 부분 경로도 앞부분 일치');
        }
    }

    /**
     * @description NextPath에 슬래시가 없는 경우 테스트
     */
    @IsTest
    static void testNextPathWithoutSlash() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given
            PathFinder kFinder = new PathFinder('/api', '/api/users');

            // When & Then - NextPath에 슬래시가 없어도 자동으로 추가됨
            Assert.isTrue(kFinder.find('users'), 'users (슬래시 없음)');
            Assert.isTrue(kFinder.find('/users'), '/users (슬래시 있음)');
        }
    }

    /**
     * @description 다단계 경로 조합 테스트
     */
    @IsTest
    static void testMultiLevelPathCombination() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given
            PathFinder kFinder = new PathFinder('/api/v1.0/users', '/api/v1.0/users/123/profile/edit');

            // When & Then
            Assert.isTrue(kFinder.find('/123/profile/edit'), '다단계 경로 정확히 매칭');
            Assert.isTrue(kFinder.find('/123/profile'), '부분 경로는 앞부분 일치');
            Assert.isTrue(kFinder.find('/123'), '더 짧은 부분 경로도 앞부분 일치');
            Assert.isFalse(kFinder.find('/profile/edit'), '시작 부분이 다르면 불일치');
        }
    }

    /**
     * @description 경로 정규화 일관성 테스트
     */
    @IsTest
    static void testPathNormalizationConsistency() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given - 모든 경로에 trailing slash
            PathFinder kFinder = new PathFinder('/api/', '/api/users/');

            // When & Then - trailing slash가 제거되고 비교됨
            Assert.isTrue(kFinder.find('/users'), 'trailing slash 자동 제거');
            Assert.isTrue(kFinder.find('/users/'), 'trailing slash 있어도 동일');
        }
    }

    /**
     * @description 불일치 케이스 테스트
     */
    @IsTest
    static void testMismatchCases() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given
            PathFinder kFinder = new PathFinder('/api/v1.0', '/api/v1.0/users/profile');

            // When & Then - 여러 케이스
            Assert.isTrue(kFinder.find('/users'), '부분 경로는 앞부분 일치');
            Assert.isTrue(kFinder.find(''), '빈 경로는 루트 경로로 앞부분 일치');
            Assert.isFalse(kFinder.find('/users/profile/extra'), '더 긴 경로 불일치');
            Assert.isFalse(kFinder.find('/orders/profile'), '완전히 다른 경로 불일치');
        }
    }

    /**
     * @description 앞부분 일치 테스트
     */
    @IsTest
    static void testPrefixMatching() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given - OriginPath가 더 긴 경로
            PathFinder kFinder = new PathFinder('/api', '/api/v1.0/users/123/profile/settings');

            // When & Then - 점진적으로 경로를 늘려가며 앞부분 일치 확인
            Assert.isTrue(kFinder.find('/v1.0'), '앞부분 일치 - v1.0');
            Assert.isTrue(kFinder.find('/v1.0/users'), '앞부분 일치 - v1.0/users');
            Assert.isTrue(kFinder.find('/v1.0/users/123'), '앞부분 일치 - v1.0/users/123');
            Assert.isTrue(kFinder.find('/v1.0/users/123/profile'), '앞부분 일치 - v1.0/users/123/profile');
            Assert.isTrue(kFinder.find('/v1.0/users/123/profile/settings'), '정확히 일치');

            // 더 긴 경로는 불일치
            Assert.isFalse(kFinder.find('/v1.0/users/123/profile/settings/extra'), '더 긴 경로는 불일치');
        }
    }

    /**
     * @description 경계 조건 테스트 - 슬래시 경계 확인
     */
    @IsTest
    static void testBoundaryConditions() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given
            PathFinder kFinder = new PathFinder('/api', '/api/users123');

            // When & Then - '/api/users'는 '/api/users123'의 앞부분이 아님 (슬래시 경계 때문에)
            Assert.isFalse(kFinder.find('/users'), '/users는 /users123의 앞부분이 아님');
            Assert.isTrue(kFinder.find('/users123'), '/users123는 정확히 일치');
        }
    }
}
