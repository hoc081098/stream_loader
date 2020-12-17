// ignore_for_file: public_member_api_docs

extension ScopeFunction<T> on T {
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  R let<R>(R Function(T) block) => block(this);
}
