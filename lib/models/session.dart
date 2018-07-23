class Session {
  final String sessionId;
  final String from;
  final String fromName;
  final String to;
  final String toName;
  final String imageName;
  final String guess;
  final int answer;

  Session({
    this.sessionId,
    this.from,
    this.fromName,
    this.to,
    this.toName,
    this.imageName,
    this.guess,
    this.answer,
  });
}
