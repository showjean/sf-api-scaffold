/**
 * @description Composite 패턴의 Composite 역할 - 여러 하위 라우터/프로세서를 관리 (상대 경로 지원)
 */
public class CompositeRouter implements APIRouter {
    private final List<RouteEntry> routes;

    /**
     * @description 경로 정규화 - trailing slash 제거
     * @param aPath 원본 경로
     * @return 정규화된 경로
     */
    private static String normalizePath(String aPath) {
        if (String.isBlank(aPath)) {
            return '/';
        }

        // 와일드카드 패턴은 정규화하지 않음
        if (aPath.contains('*')) {
            return aPath;
        }

        // trailing slash 제거 (루트 경로는 유지)
        if (aPath.length() > 1 && aPath.endsWith('/')) {
            return aPath.substring(0, aPath.length() - 1);
        }

        return aPath;
    }

    /**
     * @description RouteEntry 내부 클래스 - 경로와 처리자를 매핑
     */
    private class RouteEntry {
        final String pattern;
        final Object handler; // APIRouter 또는 APIProcessor

        RouteEntry(String aPattern, Object aHandler) {
            this.pattern = normalizePath(aPattern);
            this.handler = aHandler;
        }

        /**
         * @description 경로 매칭 확인 (PathFinder 사용)
         * @param aPrevPath 지나온 경로
         * @param aPath 요청 경로
         * @return 매칭 여부
         */
        Boolean matches(String aPrevPath, String aPath) {
            System.debug(LoggingLevel.DEBUG, this.handler.toString().substringBefore(':') +
                    ', matches() prevPath:' + aPrevPath + ', pattern:' + this.pattern + ', path:' + aPath);

            // PathFinder를 사용하여 매칭 확인
            PathFinder kFinder = new PathFinder(aPrevPath, aPath);
            return kFinder.matches(this.pattern);
        }

    }

    /**
     * @description 기본 생성자 (하위 호환성)
     */
    public CompositeRouter() {
        this.routes = new List<RouteEntry>();
    }

    /**
     * @description 하위 Router 등록
     * @param aPattern 경로 패턴
     * @param aRouter APIRouter 구현체
     * @return CompositeRouter 인스턴스 (체이닝용)
     */
    public CompositeRouter addRouter(String aPattern, APIRouter aRouter) {
        this.routes.add(new RouteEntry(aPattern, aRouter));
        return this;
    }

    /**
     * @description Processor 등록 (Leaf)
     * @param aPattern 경로 패턴
     * @param aProcessor APIProcessor 구현체
     * @return CompositeRouter 인스턴스 (체이닝용)
     */
    public CompositeRouter addProcessor(String aPattern, APIProcessor aProcessor) {
        this.routes.add(new RouteEntry(aPattern, aProcessor));
        return this;
    }

    /**
     * @description APIRouter 인터페이스 구현 - 경로에 맞는 Processor 반환
     * @param aPrevPath 지나온 경로
     * @param aPath 요청 경로
     * @return 매칭된 APIProcessor
     */
    public APIProcessor route(String aPrevPath, String aPath) {
        System.debug(LoggingLevel.INFO, 'CompositeRouter.route() - PrevPath: ' + aPrevPath + ', Path: ' + aPath);

        PathFinder kPathFinder = new PathFinder('', '');
        String kEffectivePrevPath = aPrevPath;

        for (RouteEntry kEntry : this.routes) {
            if (kEntry.matches(kEffectivePrevPath, aPath)) {
                // 새로운 prevPath 계산: 와일드카드 패턴은 /* 제거
                String kNewPrevPath;
                if (kEntry.pattern.endsWith('/*')) {
                    // 중첩 라우팅을 위해 trailing /* 제거
                    String kPatternWithoutWildcard = kEntry.pattern.substring(0, kEntry.pattern.length() - 2);
                    kNewPrevPath = kPathFinder.combine(kEffectivePrevPath, kPatternWithoutWildcard);
                }
                else {
                    kNewPrevPath = kPathFinder.combine(kEffectivePrevPath, kEntry.pattern);
                }

                // Composite인 경우 재귀적으로 route() 호출
                if (kEntry.handler instanceof APIRouter) {
                    return ((APIRouter)kEntry.handler).route(kNewPrevPath, aPath);
                }
                // Leaf인 경우 Processor 직접 반환
                else if (kEntry.handler instanceof APIProcessor) {
                    return (APIProcessor)kEntry.handler;
                }
            }
        }
        return null;
    }
}
