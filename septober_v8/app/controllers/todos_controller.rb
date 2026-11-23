class TodosController < ApplicationController
  before_action :login_required, unless: -> { request.format.json? }

  def index
    user_id = current_user&.id || User.first&.id # Fallback for CLI testing without auth
    filter_conditions = { user_id: user_id }
    if params[:add_project]
      project = Project.find_by(name: params[:add_project], user_id: current_user.id)
      filter_conditions[:project_id] = project.id if project
    else
      # TODO: Implement home_visible logic properly if needed
    end

    @todos = Todo.where(filter_conditions)
                 .search(params[:q])
                 .includes(:project)
                 .order(active: :desc, priority: :desc, updated_at: :desc)
                 .limit(100)

    respond_to do |format|
      format.html
      format.json { render json: @todos }
      format.xml  { render xml: @todos }
    end
  end

  def show
    @todo = Todo.find_by(id: params[:id], user_id: current_user.id)
    respond_to do |format|
      format.html
      format.json { render json: @todo }
      format.xml  { render xml: @todo }
    end
  end

  def new
    @todo = Todo.new
  end

  def create
    @todo = Todo.new(todo_params)
    @todo.user = current_user
    if @todo.save
      flash[:notice] = "Successfully created todo ##{@todo.id} '#{@todo.to_s}'"
      redirect_to todos_url
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @todo = Todo.find_by(id: params[:id], user_id: current_user.id)
    if turbo_frame_request?
      render partial: "inline_form", locals: { todo: @todo }
    else
      render :edit
    end
  end

  def update
    @todo = Todo.find(params[:id])
    if @todo.update(todo_params)
      if turbo_frame_request?
        render partial: "todo", locals: { todo: @todo }
      else
        flash[:notice] = "Successfully updated todo ##{@todo.id}"
        redirect_to todos_url
      end
    else
      if turbo_frame_request?
        render partial: "inline_form", locals: { todo: @todo }, status: :unprocessable_entity
      else
        render :edit, status: :unprocessable_entity
      end
    end
  end

  def destroy
    @todo = Todo.find(params[:id])
    @todo.destroy
    flash[:notice] = "Successfully destroyed todo ##{@todo.id}."
    redirect_to todos_url
  end

  def toggle
    _update_active(:toggled)
  end

  def done
    _update_active(:deactivated, false)
  end

  def undone
    _update_active(:reactivated, true)
  end

  def set_priority
    _update_field(:priority, params[:new_priority])
  end

  def procrastinate
    n_days = params.fetch(:procrastinate_days, 7).to_i
    _update_field(:due, Date.today + n_days)
  end

  def sleep
    n_days = params.fetch(:hide_until_days, 8).to_i
    _update_field(:hide_until, Time.now + n_days.days)
  end

  def seed_fake_data
    unless Rails.env.development? || Rails.env.test?
      head :forbidden
      return
    end
    user = current_user || User.first
    projects_spec = {
      "work"     => { color: "#10B981", desc: "Google DevRel, SRE, HSLU talks, slides & Buganizer" },
      "personal" => { color: "#FACC15", desc: "Personal coding, Ruby, Obsidian, dotfiles & AI tools" },
      "family"   => { color: "#EC4899", desc: "Famiglia Carlesso: Ale, Seby, Kate, Kids Own Stories & Casa T27" },
      "salute"   => { color: "#06B6D4", desc: "Salute, Mounjaro, Podologa, MediTrack & benessere" },
      "respec"   => { color: "#F97316", desc: "Spec-Driven Development (~/git/respec), 3D games & prototypes" },
      "septober" => { color: "#A855F7", desc: "Septober GTD Dispatcher, A2UI Overhaul & Auto-Banana" }
    }
    proj_map = {}
    projects_spec.each do |name, cfg|
      p = Project.find_or_initialize_by(name: name, user_id: user.id)
      p.color = cfg[:color]
      p.description = cfg[:desc]
      p.active = true
      p.home_visible = true
      p.save!
      proj_map[name] = p
    end

    samples = [
      { proj: "work", prio: 5, due: 0, src: "cli-26/Ermete@mini-lobby", img: "/auto_banana/todo_28.png", name: "Harness Engineering per Rubisti e HSLU: deck 3 slide", desc: "Preparare deck 3 slide su pre-dev, harness engineering loop e post-dev deterministic verification per talk HSLU." },
      { proj: "work", prio: 4, due: 1, src: "cli-26/Ermete@mini-lobby", img: "/auto_banana/todo_27.png", name: "Slide Deck Storia AI: Diffusion Models e Multimedia Generation", desc: "Nel deck #1 sulla storia di AI Everything: inserire slide su Midjourney, Stable Diffusion, Imagen, Veo, Lyria e Suno." },
      { proj: "work", prio: 4, due: -1, src: "cli-26/Ermete@mini-lobby", img: "/auto_banana/todo_34.png", name: "Newsletter Lavoro: Rubrica La Distilleria SRE o SRE Cicchetto", desc: "Lanciare la rubrica periodica di pillole SRE ed esperienze reali di produzione e incident management." },
      { proj: "work", prio: 3, due: 2, src: "web/riccardo", img: "/auto_banana/todo_42.png", name: "Creare glossario aziendale go/1ps-glossary", desc: "Raccogliere e documentare gli acronimi chiave e i flussi 1PS per i nuovi membri del team." },
      { proj: "family", prio: 5, due: 0, src: "cli-26/Ermete@mini-lobby", img: "/auto_banana/todo_39.png", name: "Kids Own Stories: storyboard storia di Sebi (Il Cavalletto Marie)", desc: "Storia raccontata da Sebi (6 anni): un cavalletto magico di nome Marie apre un portale per il Mondo dei Cavalli col camion-camper." },
      { proj: "family", prio: 4, due: 1, src: "cli-26/Ermete@mini-lobby", img: "/auto_banana/todo_38.png", name: "Kids Own Stories: elaborare storia di Ale per Sebi al Pony Club", desc: "Sviluppare la storia ideata da Ale per Sebi ambientata al Pony Club con illustrazioni e voce." },
      { proj: "family", prio: 4, due: -2, src: "cli-26/Ermete@mini-lobby", img: "/auto_banana/todo_36.png", name: "FotoQuad: foto Tristan/Ale/Sebi e Papino/Sebi McDonald's", desc: "Aggiungere le nuove foto di famiglia e degli amici al catalogo del gioco FotoQuad per i bimbi." },
      { proj: "salute", prio: 5, due: 0, src: "cli-26/Ermete@mini-lobby", img: "/auto_banana/todo_44.png", name: "Iniezione Mounjaro settimanale (recupero lunedì -> martedì)", desc: "Promemoria settimanale salute: fare iniezione Mounjaro e registrare peso e note su MediTrack." },
      { proj: "salute", prio: 3, due: 0, src: "cli-26/Ermete@mini-lobby", img: "/auto_banana/todo_41.png", name: "Gocce Peclavus PODO med (Nagelweicher): applicare dopo la doccia", desc: "Gocce ammorbidenti acquistate dalla podologa da applicare tutte le sere dopo la doccia." },
      { proj: "respec", prio: 4, due: 3, src: "cli-26/Lobby@mini-lobby", img: "/auto_banana/todo_43.png", name: "Dots and Lines Deluxe: linee rosse e blu con Dual PuffinLogin", desc: "Implementare da respec/specs/games/dots-and-lines/ il gioco con Dual PuffinLogin (Ale vs Sebi / Ale vs Papino) ed effetti neon." },
      { proj: "respec", prio: 3, due: 5, src: "cli-26/Ermete@mini-lobby", img: "/auto_banana/todo_35.png", name: "Champions of Krynn 3D: Prototipo Three.js Party Shooter", desc: "Prototipo 3D ispirato al classico SSI Champions of Krynn con rotazione eroi e draconici." },
      { proj: "personal", prio: 4, due: -3, src: "web/riccardo", img: "/auto_banana/todo_30.png", name: "Rugo (Goby): Transpiler Ruby to Go per CLI veloci", desc: "Esplorare l'architettura di un transpiler Ruby-to-Go per compilare script Carlessiani in binari nativi single-file." },
      { proj: "personal", prio: 3, due: -7, src: "cli-26/Lobby@mini-lobby", img: "/auto_banana/todo_40.png", name: "Esplorare i 7 repo Obsidian di kepano (CEO Steph Ango)", desc: "Analizzare le skill, i web clipper e i pattern Markdown di Steph Ango per potenziare il vault Obsidian." },
      { proj: "personal", prio: 2, due: 0, src: "web/riccardo", img: nil, name: "Nota rapida corta (<150B senza Auto-Banana)", desc: "Creata al volo da Riccardo" }
    ]

    created = 0
    samples.each do |s|
      t = Todo.find_or_initialize_by(name: s[:name], user_id: user.id)
      t.project = proj_map[s[:proj]]
      t.priority = s[:prio]
      t.due = Date.today + s[:due]
      t.source = s[:src]
      t.photo_url = s[:img]
      t.description = s[:desc]
      t.active = true
      t.save!
      created += 1
    end
    flash[:notice] = "🧪 [DEV/TEST SEED] Creati #{created} fake/test todos con progetti colorati e sfondi Auto-Banana!"
    redirect_to todos_path
  end

  def clear_all_dev
    unless Rails.env.development? || Rails.env.test?
      head :forbidden
      return
    end
    user = current_user || User.first
    count = Todo.where(user_id: user.id).delete_all
    flash[:notice] = "🧹 [DEV/TEST] Rimossi #{count} todos (ora sei a ZERO todos e puoi testare il bottone 'Aggiungi fake/test data'!)"
    redirect_to todos_path
  end

  private

  def _update_active(participle, new_active = nil)
    @todo = Todo.find_by(id: params[:id], user_id: current_user.id)
    new_active = !@todo.active if new_active.nil?
    
    if @todo.update(active: new_active)
      flash[:notice] = "Successfully '#{participle}' todo ##{params[:id]}"
      redirect_to todos_url
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def _update_field(field_name, new_val)
    @todo = Todo.find_by(id: params[:id], user_id: current_user.id)
    if @todo.update(field_name => new_val)
      flash[:notice] = "Successfully set '#{field_name}'='#{new_val}' for Todo ##{params[:id]}"
      redirect_to todos_url
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def todo_params
    params.require(:todo).permit(:name, :description, :active, :due, :priority, :project_id, :url, :progress_status, :favorite, :hide_until, :depends_on_id, :source, :photo_url, :tag_list)
  end
end
