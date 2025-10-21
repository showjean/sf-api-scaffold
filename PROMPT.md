# 1
APIScaffold 클래스를 구현할거다.
이 시스템은 APEX 로 전달되는 Rest api (@RestResource)를 적절히 처리하는 시스템이다.

사용 예제는 다음과 같다.
```apex
APIScaffold kScaffold = APIScaffold.route('/api/v1.0/*', new APIRouterV1())
.route('/api/v2.0/*', new APIRouterV2())
.exception(new APIRouterExceptionHandler())
.create();

kScaffold.process(RestRequest, RestResponse); // APEX Rest 처리
```

APIRouterV1, APIRouterV2 등 Router 객체는 Composite 패턴으로 구현돼있다.
APIScaffold.process() 전달되는 요청을 라우터에 설정된 경로에 해당 APIProcessor 가 응답한다.
일치하는 경로가 없다면 사용자가 정한 예외 형식으로 Response 를 반환한다.

이런 시스템에 대한 의견과 다이어그램 보여줘.

APIRouter 는 Composite 패턴으로 구현하려고하는데 맞아?

APIRouter 는 route() 로 APIProcesser 를 반환하도록해서, routing 과 processing 인터페이스를 분리해줘.

# 2
CompositeRouter 에 보면 `:` 로 구분되는 경로 변수를 처리하고 있는데, apex 는 이런 형식은 없고, `*`만 지원한다. 고려해서 수정해줘.

`/api/v1.0/*/view` 처럼 중간에 와일드카드가 사용되는 경우도 있으니까 반영해줘.

# 3
현재 route 경로 처리는 항상 절대 경로로서 하고 있다. 그러면, 하위 라이터를 다른 부모에 연결할 경우, 호환이되지 않게 되겠지.
그러니, 라이팅 처리를 부모의 경로를 제외한 상대 경로로 처리하도록 수정할 수 있을까?

# 4
CompositeRouter.matches() 에서 pattern 과 path 에 마지막 문자가 한쪽에만 `/` 인 경우 다른 것으로 판단하는데, 이를 같다고 판단하면 문제가 될까?

# 5
CompositeRouter.matches() 의 규칙과 CompositeRouter.toRelativePath() 의 규칙이 맞지 않아보이는데, 그래서 일치한 경로라도 다음 단계에서는 불일치가 된다.
예를 들면 `/api/*/health` 로 경로를 설정하고, `/api/v1.0/health` 로 요청하면 올바른 라우터를 찾지 못해.

그럼, APIRouter.route() 에 파라메터를 추가해서 지나온 경로를 추적할 수 있으면 중간 와일드카드에도 라우터를 등록할 수 있을까?

# 6
PathFinder 클래스를 만든다. .find(PrevPath, OriginPath) 메서드를 이용하여 주어지는 지나온 경로와 요청 경로를 바탕으로 등록된 PathEntry 중 적합한 하나의 엔트리를 찾는다.
PathEntry 는 계층 구조를 위하여 필요한 만큼의 상대경로를 갖고 있다. 경로에 와일드 카드는 허용하지 않는다.
이렇게 하나 만들어줘.

더 간단하게 수정해보자. PathFinder 생성자에 지나온 경로와, 원본 경로를 주고, .find(nextPath) 로 가능하면 true, 아니면 false 를 반환하는 방식으로 변경해줘.
원본 경로와 완벽히 일치하지 않더라도 앞부분이 일치하면 유효한 걸로 판단해줘.