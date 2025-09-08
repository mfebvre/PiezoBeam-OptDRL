classdef Env_Active_crtl_freq_time < rl.env.MATLABEnvironment
    %MYENVIRONMENT: Template for defining custom environment in MATLAB.    
    
    %% Properties (set properties' attributes accordingly)
    properties
        % Specify and initialize environment's necessary properties    
        Figure
        %% State Space
        Sys_rs
       
        % Sample time
        Ts 
        
        q

        w10
        
        action_D_opt
        
        time

        Tf
        
        input_signal
        
        q10_plot

        w10_plot

        noise
        
        q0

        w10_0
    end
    
    properties
        % Initialize system state [q0 w0]'
        State = zeros(2,1)
         
    end

    properties (Transient,Access = private)
        Visualizer = []
    end

    properties(Access = protected)
        % Initialize internal flag to indicate episode termination
        IsDone = false        
    end
%     methods (Abstract,Access = protected)
%         Rvalue = getRvalue(this,action)
%         
%         Reward = getReward(this,x,force)
%     end 

    %% Necessary Methods
    methods             

        % Contructor method creates an instance of the environment
        % Change class name and constructor name accordingly
        function this = Env_Active_crtl_freq_time(input_Sys_rs,input_Ts,input_Tf,Obsinfo, Actinfo,noise,time)
                      
            % Initialize Observation settings
            ObservationInfo = Obsinfo;
            % Initialize Action settings   
            ActionInfo = Actinfo;
            
            % The following line implements built-in functions of RL env
            this = this@rl.env.MATLABEnvironment(ObservationInfo,ActionInfo)
            
            % Initialize property values and pre-compute necessary values
            %updateActionInfo(this);

            this.Sys_rs=input_Sys_rs;
            this.Ts=input_Ts;
            this.Tf=input_Tf;
            this.noise=noise
            this.time=time
            disp('init')
            
        end
        
        % Apply system dynamics and simulates the environment with the 
        % given action for one step.
        function [Observation,Reward,IsDone,LoggedSignals] = step(this,Action)
            LoggedSignals = [];

                        % Get action
                       Action
            
            this.action_D_opt = Action(1);  
          
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            s = tf([1 0],[0 1]);
            Fc=5e4/2/pi

            Controle =this.action_D_opt*s*Fc/(s+Fc);
            Sys_rs_contr = feedback(this.Sys_rs,Controle,1,1);
            
            this.w10=lsim(Sys_rs_contr(end-1,2),this.noise,this.time);
            this.q=lsim(Sys_rs_contr(1,2),this.noise,this.time);
          

            Observation(1) = rms(this.q)*1e3;
            Observation(2) = rms(this.w10)*1e3;
                                   
            Reward=getReward(this) ;           
            
            if isnan(Reward)
                 Reward = 0
            end
%             
            this.State(1) = Observation(1);
            this.State(2) = Observation(2);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            IsDone = this.time(end) == this.Tf ;
            this.IsDone = IsDone;
            
                       
            % (optional) use notifyEnvUpdated to signal that the 
            % environment has been updated (e.g. to update visualization)
            %varargout = plot(this);
        end
        
        % Reset environment to initial state and output initial observation
        function InitialObservation = reset(this)
            
            this.w10_0=lsim(this.Sys_rs(end-1,2),this.noise,this.time);
            this.q0=lsim(this.Sys_rs(1,2),this.noise,this.time);
            
            InitialObservation = [rms(this.q0 );rms(this.w10_0)]*1e3;
            this.State = InitialObservation;
            
            % (optional) use notifyEnvUpdated to signal that the 
            % environment has been updated (e.g. to update visualization)
            %notifyEnvUpdated(this);
        end

        function varargout = plot(this)
            % Visualizes the environment
            if isempty(this.Visualizer) || ~isvalid(this.Visualizer)
                this.Visualizer = Beam_Visualizer_v2(this);
            else
                bringToFront(this.Visualizer);
            end
            if nargout
                varargout{1} = this.Visualizer;
            end
           
        end
        
    end

    

    %% Optional Methods (set methods' attributes accordingly)
    methods               
        % Helper methods to create the environment
                
                
        % (optional) Visualization method
                  
        function set.Ts(this,val)
            validateattributes(val,{'numeric'},{'finite','real','positive','scalar'},'','Ts');
            this.Ts = val;
        end
        function Reward = getReward(this)
            Reward = 20*log10(rms(this.w10_0)/rms(this.w10));
        end
    end
   
end
