class Session {
  final String session_id;
  final String from;
  final String from_name;
  final String to;
  final String to_name;
  final String image_name;
  final String guess;
  final int answer;

  Session({
    this.session_id,
    this.from,
    this.from_name,
    this.to,
    this.to_name,
    this.image_name,
    this.guess,
    this.answer,
  });
}
