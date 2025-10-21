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