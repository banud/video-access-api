class VideosController < ApplicationController
  before_action :set_video, only: [:update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, with: :invalid_video

  # curl -X GET http://localhost:3000/videos
  def index
    all_videos = Video.all.map do |video| 
      video.jsonify 
    end

    render json: { videos: all_videos, success: true }
  end

  # curl -X POST --data "title=title&desc=description&actors=Tom+Cruise%2CJohn+Smith%2CAngelina+Jolie&directors=Steven+Spielberg" http://localhost:3000/videos
  def create
    @video = Video.new(video_params)

    actors    = params[:actors].split(',')
    directors = params[:directors].split(',')

    @video.add_actors(actors)
          .add_directors(directors)

    if @video.save
      render json: { video: @video.jsonify, success: true }, status: :created, location: @video
    else
      render json: @video.errors, status: :unprocessable_entity
    end
  end

  # curl -X PUT --data "title=new+title&desc=new+description&actors=Tom+Cruise%2CJohn+Smith%2CAngelina+Jolie&directors=Steven+Spielberg" http://localhost:3000/videos/1
  def update
    @video = Video.find(params[:id])

    if @video.update(video_params)
      render json: { video: @video.jsonify, success: true }
    end
  end

  # curl -X DELETE http://localhost:3000/videos/1
  def destroy
    video_data = @video.jsonify

    if @video.destroy
      render json: { video: video_data, success: true }
    end
  end

  private

    def set_video
      @video = Video.find(params[:id])
    end

    def video_params
      params.permit(:title, :desc)
    end

    def invalid_video
      render json: { success: false, error: "invalid video ID"}
    end

end
