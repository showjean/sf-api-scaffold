/**
 * @description Composite 패턴의 Composite 역할 - 여러 하위 라우터/프로세서를 관리
 */
public class CompositeRouter implements APIRouter {
    private List<RouteEntry> routes;

    /**
     * @description RouteEntry 내부 클래스 - 경로와 처리자를 매핑
     */
    private class RouteEntry {
        String pattern;
        Object handler; // APIRouter 또는 APIProcessor

        RouteEntry(String aPattern, Object aHandler) {
            this.pattern = aPattern;
            this.handler = aHandler;
        }

        /**
         * @description 경로 매칭 확인
         * @param aPath 요청 경로
         * @return 매칭 여부
         */
        Boolean matches(String aPath) {
            // 정확한 경로 매칭
            if (this.pattern == aPath) {
                return true;
            }

            // 와일드카드(*) 매칭
            if (this.pattern.endsWith('/*')) {
                String kPrefix = this.pattern.substring(0, this.pattern.length() - 2);
                return aPath.startsWith(kPrefix);
            }

            // 파라미터(:id) 매칭
            if (this.pattern.contains(':')) {
                return this.matchesWithParams(aPath);
            }

            return false;
        }

        /**
         * @description 경로 파라미터를 포함한 매칭
         * @param aPath 요청 경로
         * @return 매칭 여부
         */
        private Boolean matchesWithParams(String aPath) {
            List<String> kPatternParts = this.pattern.split('/');
            List<String> kPathParts = aPath.split('/');

            if (kPatternParts.size() != kPathParts.size()) {
                return false;
            }

            for (Integer i = 0; i < kPatternParts.size(); i++) {
                String kPatternPart = kPatternParts[i];
                String kPathPart = kPathParts[i];

                // 파라미터 부분은 모두 매칭으로 간주
                if (kPatternPart.startsWith(':')) {
                    continue;
                }

                // 일반 부분은 정확히 일치해야 함
                if (kPatternPart != kPathPart) {
                    return false;
                }
            }

            return true;
        }
    }

    /**
     * @description 기본 생성자
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
     * @param aPath 요청 경로
     * @return 매칭된 APIProcessor
     */
    public APIProcessor route(String aPath) {
        for (RouteEntry kEntry : this.routes) {
            if (kEntry.matches(aPath)) {
                // Composite인 경우 재귀적으로 route() 호출
                if (kEntry.handler instanceof APIRouter) {
                    return ((APIRouter)kEntry.handler).route(aPath);
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
